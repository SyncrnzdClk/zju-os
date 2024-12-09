    .extern start_kernel
    .extern _traps
    .extern clock_set_next_event
    .extern task_init
    .extern mm_init
    .extern setup_vm
    .extern setup_vm_final
    .section .text.init
    .globl _start
    .globl relocate
_start:
    # ------------------
    # - your code here -
    la sp, boot_stack_top

    # call setup_vm
    call setup_vm

    # call relocate
    call relocate

    # initialize the memory management
    call mm_init

    call setup_vm_final

    # init the tasks before starting the kernel
    call task_init

    # set stvec = _traps
    la t0, _traps
    csrw stvec, t0
    
    # set sie[STIE] = 1, STIE is the 5th bit
    # csrr t0, sie
    # li t1, 1 << 5
    # or t0, t0, t1
    # csrw sie, t0

    # set first time interrupt
    # call clock_set_next_event
    rdtime a0
    li t0, 100000
    add a0, a0, t0
    call sbi_set_timer
    
    # set sstatus[SIE] = 1, SIE is the 1st bit
    csrr t0, sstatus
    li t1, 1 << 1
    or t0, t0, t1

    # set sstatus[SUM] = 1
    li t1, 1 << 18
    or t0, t0, t1
    csrw sstatus, t0
    
    j start_kernel
    # ------------------


relocate:
    # set ra = ra + PA2VA_OFFSET
    # set sp = sp + PA2VA_OFFSET (If you have set the sp before)

    ###################### 
    #   YOUR CODE HERE   #
    ######################
    
    # load the value PA2VA_OFFSET in a reg
    lui t0, 0xffdf8
    slli t0, t0, 16

    # set ra = ra + PA2VA_OFFSET
    add ra, ra, t0
    
    # set sp = sp + PA2VA_OFFSET
    add sp, sp, t0

    
    # set satp with early_pgtbl
    
    # need a fence to ensure the new translations are in use
    sfence.vma zero, zero
    
    ###################### 
    #   YOUR CODE HERE   #
    ######################
    
    # set mode value
    li t1, 0x8
    slli t1, t1, 60

    # set asid value
    li t2, 0
    slli t2, t2, 44


    # set PPN
    la t3, early_pgtbl
    srli t3, t3, 12

    # merge these three values
    or t3, t3, t2
    or t3, t3, t1

    # set satp
    csrw satp, t3

    ret

    .section .bss.stack
    .globl boot_stack

boot_stack:
    .space 4096 # <-- change to your stack size

    .globl boot_stack_top
boot_stack_top:
