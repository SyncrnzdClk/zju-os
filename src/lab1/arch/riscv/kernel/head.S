    .extern start_kernel
    .extern _traps
    .extern clock_set_next_event
    .section .text.init
    .globl _start
_start:
    # #error Unimplemented
    # ------------------
    # - your code here -
    la sp, boot_stack_top

    # set stvec = _traps
    la t0, _traps
    csrw stvec, t0
    
    # set sie[STIE] = 1, STIE is the 5th bit
    csrr t0, sie
    li t1, 1 << 5
    or t0, t0, t1
    csrw sie, t0

    # set first time interrupt
    call clock_set_next_event
    
    # set sstatus[SIE] = 1, SIE is the 1st bit
    csrr t0, sstatus
    li t1, 1 << 1
    or t0, t0, t1
    csrw sstatus, t0

    j start_kernel
    # ------------------

    .section .bss.stack
    .globl boot_stack
boot_stack:
    .space 4096 # <-- change to your stack size

    .globl boot_stack_top
boot_stack_top: