#include "../include/syscall.h"
#include "proc.h"
extern struct task_struct *current; 
uint64_t write(uint64_t fd, const char* buf, uint64_t count){
    // print buf
    if (fd == 1){
        for (int i = 0; i < count; i++){
            printk("%c", buf[i]);
        }
    }
    else {
        printk("fd != 1");
    }
    // return the number of characters that have been printed
    return count;
}

uint64_t getpid(){
    // return the current task's pid
    return current->pid;
}

