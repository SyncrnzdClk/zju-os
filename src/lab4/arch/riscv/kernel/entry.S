    .extern trap_handler
    .extern dummy
    .global __dummy
    .section .text.entry
    .align 2
    .globl _traps
    .global __switch_to 
_traps:
    # check if it is in the kernel state, now t0 denotes the value of sscratch
    csrr t0, sscratch
    # jump to real trap process if it is in the kernel state, else switch stack
    beq t0, zero, _traps_real
    # switch the user stack and the kernel stack
    mv t1, sp
    mv sp, t0
    csrw sscratch, t1

_traps_real:
    # 1. save 32 registers and sepc to stack
    addi sp, sp, -33*8 # x0 is not saved
    sd ra, 0(sp)            
    sd sp, 8(sp)
    sd gp, 16(sp)
    sd tp, 24(sp)
    sd t0, 32(sp)
    sd t1, 40(sp)
    sd t2, 48(sp)
    sd s0, 56(sp)
    sd s1, 64(sp)
    sd a0, 72(sp)
    sd a1, 80(sp)
    sd a2, 88(sp)
    sd a3, 96(sp)
    sd a4, 104(sp)
    sd a5, 112(sp)
    sd a6, 120(sp)
    sd a7, 128(sp)
    sd s2, 136(sp)
    sd s3, 144(sp)
    sd s4, 152(sp)
    sd s5, 160(sp)
    sd s6, 168(sp)
    sd s7, 176(sp)
    sd s8, 184(sp)
    sd s9, 192(sp)
    sd s10, 200(sp)
    sd s11, 208(sp)
    sd t3, 216(sp)
    sd t4, 224(sp)
    sd t5, 232(sp)
    sd t6, 240(sp)
   
    # save sepc
    csrr t0, sepc      
    sd t0, 248(sp)    

    # 2. call trap_handler

    # pass the arguments
    csrr a0, scause
    csrr a1, sepc
    mv a2, sp

    # call trap_handler
    call trap_handler
    
    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
    
    # first restore sepc
    ld t0, 248(sp)
    csrw sepc, t0

    # restore 32 registers (sp is the last one to be restored)
    ld t6, 240(sp)
    ld t5, 232(sp)
    ld t4, 224(sp)
    ld t3, 216(sp)
    ld s11, 208(sp)
    ld s10, 200(sp)
    ld s9, 192(sp)
    ld s8, 184(sp)
    ld s7, 176(sp)
    ld s6, 168(sp)
    ld s5, 160(sp)
    ld s4, 152(sp)
    ld s3, 144(sp)
    ld s2, 136(sp)
    ld a7, 128(sp)
    ld a6, 120(sp)
    ld a5, 112(sp)
    ld a4, 104(sp)
    ld a3, 96(sp)
    ld a2, 88(sp)
    ld a1, 80(sp)
    ld a0, 72(sp)
    ld s1, 64(sp)
    ld s0, 56(sp)
    ld t2, 48(sp)
    ld t1, 40(sp)
    ld t0, 32(sp)
    ld tp, 24(sp)
    ld gp, 16(sp)
    ld ra, 0(sp)
    ld sp, 8(sp)

    # reset sp
    addi sp, sp, 33*8

    # just return if it was in the kernel state at first
    beq t0, zero, __return
    # switch user stack and kernel stack
    csrr t0, sscratch
    mv t1, sp
    mv sp, t0
    csrw sscratch, t1

__return:
    # 4. return from trap
    sret

__dummy:
    la t0, dummy # load the address of dummy into the t0 register
    csrw sepc, t0
    
    # switch the user stack and the kernel stack
    csrr t0, sscratch
    mv t1, sp
    mv sp, t0
    csrw sscratch, t1
    sret # the program will return to the address of dummy

__switch_to:

    # TODO: might need to be fixed
    # save states to prev process
    # a0 is the base address of task_struct prev, and the content of thread starts from 32(a0)
    sd ra, 32(a0)
    sd sp, 40(a0)
    sd s0, 48(a0)
    sd s1, 56(a0)
    sd s2, 64(a0)
    sd s3, 72(a0)
    sd s4, 80(a0)
    sd s5, 88(a0)
    sd s6, 96(a0)
    sd s7, 104(a0)
    sd s8, 112(a0)
    sd s9, 120(a0)
    sd s10, 128(a0)
    sd s11, 136(a0)
    csrr t0, sepc
    sd t0, 144(a0)
    csrr t0, sstatus
    sd t0, 152(a0)
    csrr t0, sscratch
    sd t0, 160(a0)
    csrr t0, satp
    sd t0, 168(a0)

    ld ra, 32(a1)
    ld sp, 40(a1)
    ld s0, 48(a1)
    ld s1, 56(a1)
    ld s2, 64(a1)
    ld s3, 72(a1)
    ld s4, 80(a1)
    ld s5, 88(a1)
    ld s6, 96(a1)
    ld s7, 104(a1)
    ld s8, 112(a1)
    ld s9, 120(a1)
    ld s10, 128(a1)
    ld s11, 136(a1)
    ld t0, 144(a1)
    csrw sepc, t0
    ld t0, 152(a1)
    csrw sstatus, t0
    ld t0, 160(a1)
    csrw sscratch, t0
    ld t0, 168(a1)
    csrw satp, t0
    # flush TLB
    sfence.vma zero, zero
    ret
