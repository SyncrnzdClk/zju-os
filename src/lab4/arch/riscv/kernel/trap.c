#include "defs.h"
#include "printk.h"
#include "proc.h"
#include "stdint.h"
#include "syscall.h"
extern void clock_set_next_event(void);

struct pt_regs {
  uint64_t general_regs[31];
};

void trap_handler(uint64_t scause, uint64_t sepc, struct pt_regs *regs) {

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
    if (scause == 8) { // environment call from U-mode
      if (regs->general_regs[16] == 172) { // a7 == SYS_GETPID
        // save the return value in a0 (now in the kernel mode)
        regs->general_regs[9] = getpid();
      }
      else if (regs->general_regs[16] == 64) { // a7 == 64
        // save the return value in a0 (now in the kernel mode)
        regs->general_regs[9] = write(regs->general_regs[9], (char*)regs->general_regs[10], regs->general_regs[11]);
      }

      // manully add 4 to sepc
      __asm__ volatile(
        "csrr t0, sepc\n"
        "addi t0, t0, 4\n"
        "csrw sepc, t0\n"
        :::
        );
        return;
    }
    printk("[trap] scause = %lu\n", scause);
  }
}
