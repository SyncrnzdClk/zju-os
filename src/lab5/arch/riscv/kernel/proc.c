#include "proc.h"
#include "defs.h"
#include "elf.h"
#include "mm.h"
#include "printk.h"
#include "stdlib.h"
#include "string.h"
#include "vm.h"

extern void __dummy();
extern uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));
extern char _sramdisk[];
extern char _eramdisk[];

struct task_struct *idle;           // idle process
struct task_struct *current;        // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此
struct task_struct *temp_task;

#define SPP_BIT (1 << 8)
#define SPIE_BIT (1 << 5)
#define SUM_BIT (1 << 18)

#define SATP_MODE_SV39 ((uint64_t)8)

static void load_bin(struct task_struct *new_task) {
  // create a mapping for uapp
  // first calculate the size of the uapp (ceil division)
  uint64_t real_size_uapp = (uint64_t)_eramdisk - (uint64_t)_sramdisk;
  uint64_t size_uapp = (real_size_uapp + PGSIZE - 1) / PGSIZE;

  // allocate some pages for the uapp
  char *uapp_space = alloc_pages(size_uapp);

  // copy the content of the uapp into the uapp_space
  memcpy(uapp_space, _sramdisk, real_size_uapp);

  // then create the address mapping for uapp
  create_mapping(new_task->pgd, USER_START, VA2PA((uint64_t)uapp_space),
                 size_uapp << 12, PRIV_U | PRIV_W | PRIV_X | PRIV_R | PRIV_V);
}

static void load_elf(struct task_struct *new_task) {
  Elf64_Ehdr *elf_header = (Elf64_Ehdr *)_sramdisk;
  // find the program header
  Elf64_Phdr *program_header_start =
      (Elf64_Phdr *)(_sramdisk + elf_header->e_phoff);
  for (int i = 0; i < elf_header->e_phnum; ++i) {
    // enumerate all the program headers
    Elf64_Phdr *program_header = program_header_start + i;
    if (program_header->p_type == PT_LOAD) { // loadable
      Log("[0x%lx, 0x%lx) offset: 0x%lx, filesz: 0x%lx, memsz: 0x%lx",
          program_header->p_vaddr,
          program_header->p_vaddr + program_header->p_memsz,
          program_header->p_offset, program_header->p_filesz,
          program_header->p_memsz);
      // align the vaddr to the page size
      uint64_t shift = program_header->p_vaddr % PGSIZE;
      uint64_t pages = (shift + program_header->p_memsz + PGSIZE - 1) / PGSIZE;
      // allocate pages for the uapp
      // char *uapp_space = alloc_pages(pages);
      // memcpy(uapp_space + shift, _sramdisk + program_header->p_offset,
      //        program_header->p_memsz);
      uint64_t priv = program_header->p_flags;
      // uint64_t priv_r = priv & PF_R ? PRIV_R : 0;
      // uint64_t priv_w = priv & PF_W ? PRIV_W : 0;
      // uint64_t priv_x = priv & PF_X ? PRIV_X : 0;
      // create the address mapping for uapp
      // create_mapping(new_task->pgd, PGROUNDDOWN(program_header->p_vaddr),
      //                VA2PA((uint64_t)uapp_space), pages << 12,
      //                PRIV_U | priv_w | priv_x | priv_r | PRIV_V);
      uint64_t priv_r = priv & PF_R ? VM_READ : 0;
      uint64_t priv_w = priv & PF_W ? VM_WRITE : 0;
      uint64_t priv_x = priv & PF_X ? VM_EXEC : 0;
      do_mmap(&new_task->mm, program_header->p_vaddr, program_header->p_memsz,
              program_header->p_offset, program_header->p_filesz,
              priv_r | priv_w | priv_x);
    }
  }
}

void task_init() {
  srand(2024);

  // 1. 调用 kalloc() 为 idle 分配一个物理页
  // 2. 设置 state 为 TASK_RUNNING;
  // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
  // 4. 设置 idle 的 pid 为 0
  // 5. 将 current 和 task[0] 指向 idle

  /* YOUR CODE HERE */
  // mm_init();
  // allocate a physical page for idle
  idle = (struct task_struct *)kalloc();

  // set the state as TASK_RUNNING
  idle->state = TASK_RUNNING;

  // set the counter and priority
  idle->counter = idle->priority = 0;

  // set the pid as 0
  idle->pid = 0;

  // set the current and task[0]
  current = idle;
  task[0] = idle;

  // 1. 参考 idle 的设置，为 task[1] ~ task[NR_TASKS - 1] 进行初始化
  // 2. 其中每个线程的 state 为 TASK_RUNNING, 此外，counter 和 priority
  // 进行如下赋值：
  //     - counter  = 0;
  //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN,
  //     PRIORITY_MAX] 之间）
  // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
  //     - ra 设置为 __dummy（见 4.2.2）的地址
  //     - sp 设置为该线程申请的物理页的高地址

  /* YOUR CODE HERE */
  // initialize all tasks as like idle
  for (int i = 1; i < NR_TASKS; i++) {
    Log("task %d", i);
    struct task_struct *new_task = (struct task_struct *)kalloc();
    new_task->mm.mmap = NULL;
    new_task->state = TASK_RUNNING;
    new_task->pid = i;

    // set counter and priority using rand
    new_task->counter = 0;
    new_task->priority =
        rand() % (PRIORITY_MAX - PRIORITY_MIN + 1) + PRIORITY_MIN;

    // set the ra and sp
    new_task->thread.ra = (uint64_t)__dummy;
    new_task->thread.sp =
        (uint64_t)new_task + PGSIZE; // notice new_task is also an address of
                                     // the struct (the bottom of the PAGE)

    Elf64_Ehdr *elf_header = (Elf64_Ehdr *)_sramdisk;
    // loading binary: set the task's sepc as the value of USER_START
    // loading elf file: set the task's sepc as the value of elf_header->e_entry
    // new_task->thread.sepc = USER_START;
    new_task->thread.sepc = elf_header->e_entry;

    // set the thread's sstatus register
    // the task can be run only when an interrupt happens. and when the
    // interrupt finishes, the sstatus of the task will set the SIE bit with the
    // value of SPIE bit.
    new_task->thread.sstatus = SUM_BIT;
    // set the sscratch register equal to thread.sp with the value of USER_END
    new_task->thread.sscratch = USER_END;

    // allocate one page for new task's pgd
    new_task->pgd = alloc_page();

    // copy the swapper_pg_dir into the new task's pgd
    memcpy(new_task->pgd, swapper_pg_dir, PGSIZE);

    // find the PPN of new_task->pgd
    // check mm.c:8 to mm.c:11
    // uint64_t ppn = ((uint64_t)((uint64_t)(new_task->pgd) -
    // (uint64_t)PA2VA_OFFSET)-PHY_START) >> 12;
    uint64_t ppn = VA2PA((uint64_t)(new_task->pgd)) >> 12;
    // set the satp value
    new_task->thread.satp = ppn | (SATP_MODE_SV39 << 60);

    load_elf(new_task);

    // allocate one page for the stack of user mode
    // char *stack_umode = alloc_page();

    // add the mapping into the pgd
    // create_mapping(new_task->pgd, PGROUNDDOWN(USER_END - 1),
    //                VA2PA((uint64_t)stack_umode), PGSIZE,
    //                PRIV_U | PRIV_W | PRIV_R | PRIV_V);
    do_mmap(&new_task->mm, USER_END - PGSIZE, PGSIZE, 0, 0,
            VM_READ | VM_WRITE | VM_ANON);

    task[i] = new_task;
  }

  printk("...task_init done!\n");
}

#if TEST_SCHED
#define MAX_OUTPUT ((NR_TASKS - 1) * 10)
char tasks_output[MAX_OUTPUT];
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
  uint64_t MOD = 1000000007;
  uint64_t auto_inc_local_var = 0;
  int last_counter = -1;
  while (1) {
    if ((last_counter == -1 || current->counter != last_counter) &&
        current->counter > 0) {
      if (current->counter == 1) {
        --(current->counter); // forced the counter to be zero if this thread is
                              // going to be scheduled
      } // in case that the new counter is also 1, leading the information not
        // printed.
      last_counter = current->counter;
      auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
      printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid,
             auto_inc_local_var);
#if TEST_SCHED
      tasks_output[tasks_output_index++] = current->pid + '0';
      if (tasks_output_index == MAX_OUTPUT) {
        for (int i = 0; i < MAX_OUTPUT; ++i) {
          if (tasks_output[i] != expected_output[i]) {
            printk("\033[31mTest failed!\033[0m\n");
            printk("\033[31m    Expected: %s\033[0m\n", expected_output);
            printk("\033[31m    Got:      %s\033[0m\n", tasks_output);
            sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN,
                             SBI_SRST_RESET_REASON_NONE);
          }
        }
        printk("\033[32mTest passed!\033[0m\n");
        printk("\033[32m    Output: %s\033[0m\n", expected_output);
        sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN,
                         SBI_SRST_RESET_REASON_NONE);
      }
#endif
    }
  }
}

// 外部的处理线程切换的函数，在entry.S中实现
extern void __switch_to(struct task_struct *prev, struct task_struct *next);

/* 线程切换入口函数 */
void switch_to(struct task_struct *next) {
  // check if the current task is the same as the next one using their unique
  // pid
  if (next->pid != current->pid) {
    // if they are not the same, call __switch_to
    printk("switch to [PID = %d PRIORITY = %d COUNTER = %d]\n", next->pid,
           next->priority, next->counter);
    // save the current task to temp_task and switch to the next task
    temp_task = current;
    current = next;
    __switch_to(temp_task, next);
  }
}

// 选择下一个要运行的线程
static int get_next_task() {
  while (true) {
    int next = 0;    // 下一个要运行的线程
    int counter = 0; // next 线程的 counter
    for (int i = 1; i < NR_TASKS; i++) {
      if (task[i] != NULL && task[i]->counter > counter) {
        // 选择 counter 最大的线程
        counter = task[i]->counter;
        next = i;
      }
    }
    if (counter > 0) { // 找到了 counter > 0 的线程
      return next;
    }
    // 所有线程的时间片都已耗尽
    for (int i = 1; i < NR_TASKS; i++) {
      if (task[i] != NULL) {
        // 重新设置时间片
        task[i]->counter = task[i]->priority;
        printk("SET [PID = %d PRIORITY = %d COUNTER = %d]\n", task[i]->pid,
               task[i]->priority, task[i]->counter);
      }
    }
  }
}

void schedule() { switch_to(task[get_next_task()]); }

void do_timer() {
  // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
  // 2. 否则对当前线程的运行剩余时间减 1，若剩余时间仍然大于 0
  // 则直接返回，否则进行调度
  if (current == idle || current->counter == 0) {
    schedule();
  } else {
    current->counter--;
    if (current->counter == 0) {
      schedule();
    }
  }
}

struct vm_area_struct *find_vma(struct mm_struct *mm, uint64_t addr) {
  for (struct vm_area_struct *vma = mm->mmap; vma != NULL; vma = vma->vm_next) {
    if (vma->vm_start <= addr && addr < vma->vm_end) {
      return vma;
    }
  }
  return NULL;
}

uint64_t do_mmap(struct mm_struct *mm, uint64_t addr, uint64_t len,
                 uint64_t vm_pgoff, uint64_t vm_filesz, uint64_t flags) {
  Log("mmap [0x%lx, 0x%lx), pgoff = 0x%lx, filesz = 0x%lx, flags = 0x%lx", addr,
      addr + len, vm_pgoff, vm_filesz, flags);
  struct vm_area_struct *vma = mm->mmap;
  struct vm_area_struct *node = (struct vm_area_struct *)kalloc();
  *node = (struct vm_area_struct){
      .vm_mm = mm,
      .vm_start = addr,
      .vm_end = addr + len,
      .vm_next = vma,
      .vm_prev = NULL,
      .vm_flags = flags,
      .vm_pgoff = vm_pgoff,
      .vm_filesz = vm_filesz,
  };
  if (vma != NULL) {
    vma->vm_prev = node;
  }
  mm->mmap = node;
  return addr;
}
