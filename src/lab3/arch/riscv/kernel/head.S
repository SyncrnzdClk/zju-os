    .extern start_kernel
    .extern _traps
    .extern clock_set_next_event
    .extern task_init
    .extern mm_init
    .extern setup_vm
    .section .text.init
    .globl _start
_start:
    # #error Unimplemented
    # ------------------
    # - your code here -
    la sp, boot_stack_top

    # call setup_vm
    call setup_vm

    # call relocate
    call relocate

    # initialize the memory management
    call mm_init

    # init the tasks before starting the kernel
    call task_init

    # set stvec = _traps
    la t0, _traps
    csrw stvec, t0
    
    # set sie[STIE] = 1, STIE is the 5th bit
    csrr t0, sie
    li t1, 1 << 5
    or t0, t0, t1
    csrw sie, t0

    # set first time interrupt
    #call clock_set_next_event
    rdtime a0
    li t0, 100000
    add a0, a0, t0
    call sbi_set_timer
    
    # set sstatus[SIE] = 1, SIE is the 1st bit
    csrr t0, sstatus
    li t1, 1 << 1
    or t0, t0, t1
    csrw sstatus, t0
    
    j start_kernel
    # ------------------

    .section .bss.stack
    .globl boot_stack

relocate:
    # set ra = ra + PA2VA_OFFSET
    # set sp = sp + PA2VA_OFFSET (If you have set the sp before)

    ###################### 
    #   YOUR CODE HERE   #
    ######################

    # need a fence to ensure the new translations are in use
    sfence.vma zero, zero

    # set satp with early_pgtbl

    ###################### 
    #   YOUR CODE HERE   #
    ######################

    ret

    .section .bss.stack
    .globl boot_stack


boot_stack:
    .space 4096 # <-- change to your stack size

    .globl boot_stack_top
boot_stack_top:
