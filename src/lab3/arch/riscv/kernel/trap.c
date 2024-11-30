#include "defs.h"
#include "printk.h"
#include "proc.h"
#include "stdint.h"
extern void clock_set_next_event(void);

void trap_handler(uint64_t scause, uint64_t sepc) {

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
    // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试
    printk("[trap] scause = %lu\n", scause);
    // printk("%llx, %d, %llx, %d\n", scause, interrupt, exception_code,
    //        timer_interrupt);
    // printk("test: 802005a8 >> 63 = %llx\n", 0x802005a8 >> 63);
  }
  // #error Unimplemented
}
