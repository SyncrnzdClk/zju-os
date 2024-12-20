#include "defs.h"
#include "mm.h"
#include "printk.h"
#include "proc.h"
#include "stdint.h"
#include "string.h"
#include "syscall.h"
#include "vm.h"
extern void clock_set_next_event(void);

struct pt_regs {
  uint64_t general_regs[31];
  uint64_t sepc, sstatus, sscratch;
};

#define INST_PAGE_FAULT 12
#define LOAD_PAGE_FAULT 13
#define STORE_PAGE_FAULT 15

static uint64_t min(uint64_t a, uint64_t b) { return a < b ? a : b; }

extern char _sramdisk[];
extern char _eramdisk[];
void do_page_fault(struct pt_regs *regs) {
  uint64_t bad_addr = csr_read(stval);
  Log("page fault at 0x%lx", bad_addr);
  struct vm_area_struct *vma = find_vma(&current->mm, bad_addr);
  if (vma == NULL) {
    Err("page fault at 0x%lx, but cannot find the vma", bad_addr);
    return;
  }
  uint64_t scause = csr_read(scause);
  if (scause == INST_PAGE_FAULT && (vma->vm_flags & VM_EXEC) == 0) {
    Err("instruction page fault at 0x%lx, but the vma is not executable",
        bad_addr);
    return;
  } else if (scause == LOAD_PAGE_FAULT && (vma->vm_flags & VM_READ) == 0) {
    Err("load page fault at 0x%lx, but the vma is not readable", bad_addr);
    return;
  } else if (scause == STORE_PAGE_FAULT && (vma->vm_flags & VM_WRITE) == 0) {
    Err("store page fault at 0x%lx, but the vma is not writable", bad_addr);
    return;
  }
  uint64_t *page = alloc_page();
  uint64_t priv_r = (vma->vm_flags & VM_READ) ? PRIV_R : 0;
  uint64_t priv_w = (vma->vm_flags & VM_WRITE) ? PRIV_W : 0;
  uint64_t priv_x = (vma->vm_flags & VM_EXEC) ? PRIV_X : 0;
  create_mapping(current->pgd, PGROUNDDOWN(bad_addr), VA2PA((uint64_t)page),
                 PGSIZE, PRIV_U | priv_r | priv_w | priv_x | PRIV_V);
  if ((vma->vm_flags & VM_ANON) == 0) {
    // bad_addr - vma->vm_start is the offset
    // copy the content of the file to the page
    uint64_t offset = bad_addr - vma->vm_start;
    uint64_t program_page =
        PGROUNDDOWN((uint64_t)_sramdisk + vma->vm_pgoff + offset);
    uint64_t page_end = PGROUNDDOWN(bad_addr) + PGSIZE;
    Log("vm_start = 0x%lx, vm_pgoff = 0x%lx, offset = 0x%lx, filesz = 0x%lx",
        vma->vm_start, vma->vm_pgoff, offset, vma->vm_filesz);
    memcpy(page, (void *)program_page, PGSIZE);
    if (vma->vm_start + vma->vm_filesz < page_end) {
      uint64_t rest = min(PGSIZE, page_end - vma->vm_start - vma->vm_filesz);
      Log("zero rest part: 0x%lx", rest);
      memset(page + PGSIZE - rest, 0, rest);
    }
  }
}

void trap_handler(uint64_t scause, uint64_t sepc, struct pt_regs *regs) {

  // printk("[trap] scause = %lu, a7 = %lu\n", scause, regs->general_regs[16]);
  // printk("in trap, the value pf sstatus is %llx \n", csr_read(sstatus));

  // 通过 `scause` 判断 trap 类型
  bool interrupt = (scause >> 63);

  // 如果是 interrupt 判断是否是 timer interrupt
  uint64_t exception_code = scause & 0x7fffffff;
  bool timer_interrupt = interrupt & (exception_code == 5);

  // 如果是 timer interrupt 则打印输出相关信息，并通过 `clock_set_next_event()`
  // 设置下一次时钟中断 printk("interrupt is %d, exception_code is %d\n",
  // interrupt, exception_code);
  if (timer_interrupt) {
    // printk("[S] Supervisor Mode Timer Interrupt\n");

    // `clock_set_next_event()` 见 4.3.4 节
    clock_set_next_event();
    do_timer();
  } else {
    Log("trap: scause = %ld, sepc = 0x%lx", scause, sepc);
    if (scause == 8) {                     // environment call from U-mode
      if (regs->general_regs[16] == 172) { // a7 == SYS_GETPID
        // save the return value in a0 (now in the kernel mode)
        regs->general_regs[9] = getpid();
      } else if (regs->general_regs[16] == 64) { // a7 == 64
        // save the return value in a0 (now in the kernel mode)
        regs->general_regs[9] =
            write(regs->general_regs[9], (char *)regs->general_regs[10],
                  regs->general_regs[11]);
      }

      // manully add 4 to sepc
      // note that sepc will be recovered in entry.S (and the value is
      // regs->sepc), so it's useless to just add 4 to csr register sepc.
      regs->sepc += 4;
      return;
    } else if (scause == INST_PAGE_FAULT || scause == LOAD_PAGE_FAULT ||
               scause == STORE_PAGE_FAULT) {
      do_page_fault(regs);
    } else {
      Err("unhandled trap: scause = %lu, sepc = 0x%lx, stval = 0x%lx", scause,
          sepc, csr_read(stval));
    }
  }
}
