#ifndef __SYSCALL_H__
#define __SYSCALL_H__

#include "defs.h"
#include "printk.h"
struct pt_regs {
  uint64_t general_regs[31];
  uint64_t sepc, sstatus, sscratch;
};

uint64_t write(uint64_t fd, const char* buf, uint64_t count);
uint64_t getpid();
uint64_t do_fork(struct pt_regs *regs);
int64_t sys_write(uint64_t fd, const char* buf, uint64_t len);
int64_t sys_read(uint64_t fd, char* buf, uint64_t len);
#define SYS_WRITE 64
#define SYS_GETPID 172
#define SYS_CLONE 220
#define SYS_READ 63

#endif