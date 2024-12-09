#include "proc.h"
#include "defs.h"
#include "mm.h"
#include "printk.h"
#include "stdlib.h"
#include "string.h"
#include "vm.h"

extern void __dummy();
extern uint64_t  swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));
extern char _sramdisk[];
extern char _eramdisk[];

struct task_struct *idle;           // idle process
struct task_struct *current;        // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此
struct task_struct *temp_task;

#define SPP_BIT (1 << 8)
#define SPIE_BIT (1 << 5)
#define SUM_BIT (1 << 18)

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
    struct task_struct *new_task = (struct task_struct *)kalloc();
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

    // set the task's sepc as the value of USER_START
    new_task->thread.sepc = USER_START;

    uint64_t spp = SPP_BIT;
    uint64_t sum = SUM_BIT;
    // set the thread's sstatus register
    // the task can be run only when an interrupt happens. and when the interrupt finishes, the sstatus of the task will set the SIE bit with the value of SPIE bit.
    __asm__ volatile(
      "csrr t0, sstatus\n"
      "or t0, t0, %[spp]\n"
      "or t0, t0, %[sum]\n"
      "mv %[ret_val], t0"
      : [ret_val] "=r" (new_task->thread.sstatus)
      : [spp] "r" (spp), [sum] "r" (sum)
      : "memory"
    );
    // set the sscratch register equal to thread.sp with the value of USER_END
    new_task->thread.sscratch = USER_END;

    // allocate one page for new task's pgd
    new_task->pgd = alloc_page();

    // copy the swapper_pg_dir into the new task's pgd
    memcpy(new_task->pgd, swapper_pg_dir, PGSIZE);

    // find the PPN of new_task->pgd
    // check mm.c:8 to mm.c:11
    // uint64_t ppn = ((uint64_t)((uint64_t)(new_task->pgd) - (uint64_t)PA2VA_OFFSET)-PHY_START) >> 12;
    uint64_t ppn = VA2PA((uint64_t)(new_task->pgd)) >> 12;
    // set the satp value
    __asm__ volatile(
    "li t1, 0x8\n"
    "slli t1, t1, 60\n"
    "li t2, 0\n"
    "slli t2, t2, 44\n"
    "mv t3, %[ppn]\n"
    "or t3, t3, t2\n"
    "or t3, t3, t1\n"
    "mv %[satp], t3\n"
      : [satp] "=r" (new_task->thread.satp)
      : [ppn] "r" (ppn)
      : "memory"
    );

    // create a mapping for uapp
    // first calculate the size of the uapp (ceil division)
    uint64_t real_size_uapp = (uint64_t)_eramdisk - (uint64_t)_sramdisk;
    uint64_t size_uapp = real_size_uapp & 0xfff == 0 ? real_size_uapp >> 12 : ((uint64_t)(real_size_uapp >> 12) + 1);

    // allocate some pages for the uapp
    char* uapp_space = alloc_pages(size_uapp);

    // copy the content of the uapp into the uapp_space
    memcpy(uapp_space, _sramdisk, real_size_uapp);

    // then create the address mapping for uapp
    create_mapping(new_task->pgd, USER_START,
                    VA2PA((uint64_t)uapp_space), size_uapp << 12,
                    PRIV_U | PRIV_W | PRIV_X | PRIV_R | PRIV_V);
    // allocate one page for the stack of user mode
    char* stack_umode = alloc_page();

    // add the mapping into the pgd
    create_mapping(new_task->pgd, PGROUNDDOWN(USER_END-1),
                    VA2PA((uint64_t)stack_umode), PGSIZE,
                    PRIV_U | PRIV_W | PRIV_R | PRIV_V);
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
    int next = 0; // 下一个要运行的线程
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
