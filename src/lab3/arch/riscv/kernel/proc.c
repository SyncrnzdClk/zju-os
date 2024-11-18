#include "proc.h"
#include "defs.h"
#include "mm.h"
#include "printk.h"
#include "stdlib.h"

extern void __dummy();

struct task_struct *idle;           // idle process
struct task_struct *current;        // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此
struct task_struct *temp_task;

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
