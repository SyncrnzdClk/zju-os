#ifndef __SYSCALL_H__
#define __SYSCALL_H__

#include "defs.h"
#include "printk.h"
uint64_t write(uint64_t fd, const char* buf, uint64_t count);
uint64_t getpid();


#endif