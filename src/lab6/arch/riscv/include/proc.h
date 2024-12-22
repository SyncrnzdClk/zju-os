#ifndef __PROC_H__
#define __PROC_H__

#include "stdint.h"
#include "fs.h"
#if TEST_SCHED
#define NR_TASKS (1 + 4) // 测试时线程数量
#else
#define NR_TASKS (1 + 1) // 用于控制最大线程数量（idle 线程 + 31 内核线程）
#endif

#define TASK_RUNNING 0 // 为了简化实验，所有的线程都只有一种状态

#define PRIORITY_MIN 1
#define PRIORITY_MAX 10
#define SATP_MODE_SV39 ((uint64_t)8)

extern uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));
// /* 线程状态段数据结构 */
// struct thread_struct {
//   uint64_t ra;
//   uint64_t sp;
//   uint64_t s[12]; // state register
// };

// /* 线程数据结构 */
// struct task_struct {
//   uint64_t state;    // 线程状态
//   uint64_t counter;  // 运行剩余时间
//   uint64_t priority; // 运行优先级 1 最低 10 最高
//   uint64_t pid;      // 线程 id

//   struct thread_struct thread;
// };

struct vm_area_struct {
  struct mm_struct *vm_mm;
  uint64_t vm_start;
  uint64_t vm_end;
  struct vm_area_struct *vm_next, *vm_prev;
  uint64_t vm_flags;
  uint64_t vm_pgoff;
  uint64_t vm_filesz;
};

struct mm_struct {
  struct vm_area_struct *mmap;
};

struct thread_struct {
  uint64_t ra;
  uint64_t sp;
  uint64_t s[12];
  uint64_t sepc, sstatus, sscratch, satp; // satp is personally added
};

struct task_struct {
  uint64_t state;
  uint64_t counter;
  uint64_t priority;
  uint64_t pid;

  struct thread_struct thread;
  uint64_t *pgd; // 用户态页表
  struct mm_struct mm;
  struct files_struct *files;
};

/* 线程初始化，创建 NR_TASKS 个线程 */
void task_init();

/* 在时钟中断处理中被调用，用于判断是否需要进行调度 */
void do_timer();

/* 调度程序，选择出下一个运行的线程 */
void schedule();

/* 线程切换入口函数 */
void switch_to(struct task_struct *next);

/* dummy funciton: 一个循环程序，循环输出自己的 pid 以及一个自增的局部变量 */
void dummy();

/**
 * @param mm   current thread's mm_struct
 * @param addr the va to look up
 *
 * @return the VMA if found or NULL if not found
 */
struct vm_area_struct *find_vma(struct mm_struct *mm, uint64_t addr);

/**
 * @param mm        current thread's mm_struct
 * @param addr      the va to map
 * @param len       memory size to map
 * @param vm_pgoff  phdr->p_offset
 * @param vm_filesz phdr->p_filesz
 * @param flags     flags for the new VMA
 *
 * @return start va
 */
uint64_t do_mmap(struct mm_struct *mm, uint64_t addr, uint64_t len,
                 uint64_t vm_pgoff, uint64_t vm_filesz, uint64_t flags);

extern struct task_struct *current;
#endif
