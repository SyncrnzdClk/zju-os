#include "../include/syscall.h"
#include "fs.h"
#include "mm.h"
#include "proc.h"
#include "string.h"
#include "vm.h"
extern struct task_struct *task[NR_TASKS];
extern struct task_struct *current;
extern int nr_tasks;
extern void __ret_from_fork();
uint64_t write(uint64_t fd, const char *buf, uint64_t count) {
  // print buf
  if (fd == 1) {
    for (int i = 0; i < count; i++) {
      printk("%c", buf[i]);
    }
  } else {
    printk("fd != 1");
  }
  // return the number of characters that have been printed
  return count;
}

uint64_t getpid() {
  // return the current task's pid
  return current->pid;
}

// utils: check and copy the content of the page table entry
void check_and_copy_pages(uint64_t *pgd, uint64_t va_start, uint64_t va_end,
                          uint64_t *new_pgd, uint64_t vm_flags) {
  // notice va is page aligned
  for (uint64_t va = PGROUNDDOWN(va_start); va < va_end; va += PGSIZE) {
    // get the page table entry
    uint64_t vpn0 = (va >> 12) & 0x1ff;
    uint64_t vpn1 = (va >> 21) & 0x1ff;
    uint64_t vpn2 = (va >> 30) & 0x1ff;

    // check if the first page table entry is valid
    if (pgd[vpn2] & PRIV_V) {
      uint64_t *pgtbl1 = get_pgtable(pgd, vpn2);
      // check if the second page table entry is valid
      if (pgtbl1[vpn1] & PRIV_V) {
        uint64_t *pgtbl0 = get_pgtable(pgtbl1, vpn1);
        // check if the third page table entry is valid
        if (pgtbl0[vpn0] & PRIV_V) {
          // if yes, deep copy the content of the page
          // notice only the machine mode has the privilege to access the
          // physical address, so we use memcpy for the virtual page address
          // here
          char *child_process_page = alloc_page();
          uint64_t priv_r = (vm_flags & VM_READ) ? PRIV_R : 0;
          uint64_t priv_w = (vm_flags & VM_WRITE) ? PRIV_W : 0;
          uint64_t priv_x = (vm_flags & VM_EXEC) ? PRIV_X : 0;
          create_mapping(new_pgd, va, VA2PA((uint64_t)child_process_page),
                         PGSIZE, PRIV_U | priv_r | priv_w | priv_x | PRIV_V);
          // copy the content of current page to the child page
          memcpy(child_process_page, (char *)va, PGSIZE);
        }
      }
    }
  }
}

uint64_t do_fork(struct pt_regs *regs) {
  // copy kernel stack
  struct task_struct *_task = (struct task_struct *)kalloc();
  memcpy(_task, current, PGSIZE);
  // assign new pid
  _task->pid = nr_tasks++;
  // assign new page directory
  _task->pgd = alloc_page();
  // set mm.mmap
  _task->mm.mmap = NULL;
  // copy the swapper_pg_dir into the new task's pgd
  memcpy(_task->pgd, swapper_pg_dir, PGSIZE);

  // iterate the vma list of the current task
  struct vm_area_struct *vma = current->mm.mmap;
  while (vma != NULL) {
    // create a new vma
    struct vm_area_struct *new_vma = (struct vm_area_struct *)kalloc();
    memcpy(new_vma, vma, sizeof(struct vm_area_struct));
    // link the new vma to the new task's mm
    new_vma->vm_mm = &(_task->mm);
    new_vma->vm_next = _task->mm.mmap;
    new_vma->vm_prev = NULL;
    // link the new vma to the new task's mm
    if (_task->mm.mmap == NULL) {
      _task->mm.mmap = new_vma;
    } else {
      // struct vm_area_struct *tmp = _task->mm.mmap;
      _task->mm.mmap->vm_prev = new_vma;
      _task->mm.mmap = new_vma;
    }
    // if the corresponding page table entry exists, copy the content
    check_and_copy_pages(current->pgd, new_vma->vm_start, new_vma->vm_end,
                         _task->pgd, new_vma->vm_flags);
    // move to the next vma
    vma = vma->vm_next;
  }
  // get the _task's pt_regs
  // struct pt_regs* test_regs = (struct pt_regs *)((uint64_t)current + PGSIZE -
  // sizeof(struct pt_regs));
  struct pt_regs *child_pt_regs =
      (struct pt_regs *)((uint64_t)_task + (uint64_t)regs - (uint64_t)current);
  child_pt_regs->general_regs[1] =
      (uint64_t)child_pt_regs;             // set child_pt_regs->sp
  child_pt_regs->sepc += 4;                // set the sepc of the child process
  _task->thread.sscratch = regs->sscratch; // the sscratch of the child process
  _task->thread.sp = (uint64_t)child_pt_regs;   // the sp of the child process
  _task->thread.ra = (uint64_t)__ret_from_fork; // the ra of the child process
  // set the return value of the child process
  child_pt_regs->general_regs[9] = 0;
  // set the satp of the chlid process
  uint64_t ppn = VA2PA((uint64_t)(_task->pgd)) >> 12;
  _task->thread.satp = ppn | (SATP_MODE_SV39 << 60);
  // add _task to the task list
  task[_task->pid] = _task;
  // return the new task's pid
  return _task->pid;
}

int64_t sys_write(uint64_t fd, const char *buf, uint64_t len) {
  int64_t ret;
  struct file *file = &(current->files->fd_array[fd]);
  if (file->opened == 0) {
    printk("file not opened\n");
    return ERROR_FILE_NOT_OPEN;
  } else {
    // check perm and call write function of file
    if (!(file->perms & FILE_WRITABLE)) {
      Err("attempt writing into a non-writable file");
    }
    ret = file->write(file, buf, len);
  }
  return ret;
}

int64_t sys_read(uint64_t fd, char *buf, uint64_t len) {
  int64_t ret;
  struct file *file = &(current->files->fd_array[fd]);
  if (file->opened == 0) {
    printk("file not opened\n");
    return ERROR_FILE_NOT_OPEN;
  } else {
    // check perm and call read function of file
    // check perm
    if (!(file->perms & FILE_READABLE)) {
      Err("read from a file that is not readable");
    }
    // call read function of file
    ret = file->read(file, buf, len);
  }
  return ret;
}
