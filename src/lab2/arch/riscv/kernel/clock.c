#include "sbi.h"
#include "stdint.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 100000;

uint64_t get_cycles() {
  uint64_t cycles;
  // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime
  // 寄存器）的值并返回
  __asm__ volatile(
      // read the time from mtime
      "rdtime %[cycles]"
      : [cycles] "=r"(cycles));
  return cycles;
  // #error Unimplemented
}

void clock_set_next_event() {
  // 下一次时钟中断的时间点
  uint64_t next = get_cycles() + TIMECLOCK;
  // printk("next time interrupt at: %d\n", next);

  // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
  sbi_set_timer(next);
  // #error Unimplemented
}
