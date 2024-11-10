
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <_skernel>:
    .globl _start
_start:
    # #error Unimplemented
    # ------------------
    # - your code here -
    la sp, boot_stack_top
    80200000:	00003117          	auipc	sp,0x3
    80200004:	02013103          	ld	sp,32(sp) # 80203020 <_GLOBAL_OFFSET_TABLE_+0x18>

    # set stvec = _traps
    la t0, _traps
    80200008:	00003297          	auipc	t0,0x3
    8020000c:	0282b283          	ld	t0,40(t0) # 80203030 <_GLOBAL_OFFSET_TABLE_+0x28>
    csrw stvec, t0
    80200010:	10529073          	csrw	stvec,t0
    
    # set sie[STIE] = 1, STIE is the 5th bit
    csrr t0, sie
    80200014:	104022f3          	csrr	t0,sie
    li t1, 1 << 5
    80200018:	02000313          	li	t1,32
    or t0, t0, t1
    8020001c:	0062e2b3          	or	t0,t0,t1
    csrw sie, t0
    80200020:	10429073          	csrw	sie,t0

    # set first time interrupt
    call clock_set_next_event
    80200024:	1ec000ef          	jal	80200210 <clock_set_next_event>
    
    # set sstatus[SIE] = 1, SIE is the 1st bit
    csrr t0, sstatus
    80200028:	100022f3          	csrr	t0,sstatus
    li t1, 1 << 1
    8020002c:	00200313          	li	t1,2
    or t0, t0, t1
    80200030:	0062e2b3          	or	t0,t0,t1
    csrw sstatus, t0
    80200034:	10029073          	csrw	sstatus,t0

    # initialize the memory management
    call mm_init
    80200038:	378000ef          	jal	802003b0 <mm_init>

    # init the tasks before starting the kernel
    call task_init
    8020003c:	3b8000ef          	jal	802003f4 <task_init>
    
    j start_kernel
    80200040:	1e50006f          	j	80200a24 <start_kernel>

0000000080200044 <_traps>:
    .global __switch_to 
_traps:
    # #error Unimplemented

    # 1. save 32 registers and sepc to stack
    addi sp, sp, -32*8 # x0 is not saved
    80200044:	f0010113          	addi	sp,sp,-256
    sd ra, 0(sp)            
    80200048:	00113023          	sd	ra,0(sp)
    sd sp, 8(sp)
    8020004c:	00213423          	sd	sp,8(sp)
    sd gp, 16(sp)
    80200050:	00313823          	sd	gp,16(sp)
    sd tp, 24(sp)
    80200054:	00413c23          	sd	tp,24(sp)
    sd t0, 32(sp)
    80200058:	02513023          	sd	t0,32(sp)
    sd t1, 40(sp)
    8020005c:	02613423          	sd	t1,40(sp)
    sd t2, 48(sp)
    80200060:	02713823          	sd	t2,48(sp)
    sd s0, 56(sp)
    80200064:	02813c23          	sd	s0,56(sp)
    sd s1, 64(sp)
    80200068:	04913023          	sd	s1,64(sp)
    sd a0, 72(sp)
    8020006c:	04a13423          	sd	a0,72(sp)
    sd a1, 80(sp)
    80200070:	04b13823          	sd	a1,80(sp)
    sd a2, 88(sp)
    80200074:	04c13c23          	sd	a2,88(sp)
    sd a3, 96(sp)
    80200078:	06d13023          	sd	a3,96(sp)
    sd a4, 104(sp)
    8020007c:	06e13423          	sd	a4,104(sp)
    sd a5, 112(sp)
    80200080:	06f13823          	sd	a5,112(sp)
    sd a6, 120(sp)
    80200084:	07013c23          	sd	a6,120(sp)
    sd a7, 128(sp)
    80200088:	09113023          	sd	a7,128(sp)
    sd s2, 136(sp)
    8020008c:	09213423          	sd	s2,136(sp)
    sd s3, 144(sp)
    80200090:	09313823          	sd	s3,144(sp)
    sd s4, 152(sp)
    80200094:	09413c23          	sd	s4,152(sp)
    sd s5, 160(sp)
    80200098:	0b513023          	sd	s5,160(sp)
    sd s6, 168(sp)
    8020009c:	0b613423          	sd	s6,168(sp)
    sd s7, 176(sp)
    802000a0:	0b713823          	sd	s7,176(sp)
    sd s8, 184(sp)
    802000a4:	0b813c23          	sd	s8,184(sp)
    sd s9, 192(sp)
    802000a8:	0d913023          	sd	s9,192(sp)
    sd s10, 200(sp)
    802000ac:	0da13423          	sd	s10,200(sp)
    sd s11, 208(sp)
    802000b0:	0db13823          	sd	s11,208(sp)
    sd t3, 216(sp)
    802000b4:	0dc13c23          	sd	t3,216(sp)
    sd t4, 224(sp)
    802000b8:	0fd13023          	sd	t4,224(sp)
    sd t5, 232(sp)
    802000bc:	0fe13423          	sd	t5,232(sp)
    sd t6, 240(sp)
    802000c0:	0ff13823          	sd	t6,240(sp)
   
    # save sepc
    csrr t0, sepc      
    802000c4:	141022f3          	csrr	t0,sepc
    sd t0, 248(sp)     
    802000c8:	0e513c23          	sd	t0,248(sp)

    # 2. call trap_handler

    # pass the arguments
    csrr a0, scause
    802000cc:	14202573          	csrr	a0,scause
    csrr a1, sepc
    802000d0:	141025f3          	csrr	a1,sepc

    # call trap_handler
    call trap_handler
    802000d4:	08d000ef          	jal	80200960 <trap_handler>
    
    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
    
    # first restore sepc
    ld t0, 248(sp)
    802000d8:	0f813283          	ld	t0,248(sp)
    csrw sepc, t0
    802000dc:	14129073          	csrw	sepc,t0

    # restore 32 registers (sp is the last one to be restored)
    ld t6, 240(sp)
    802000e0:	0f013f83          	ld	t6,240(sp)
    ld t5, 232(sp)
    802000e4:	0e813f03          	ld	t5,232(sp)
    ld t4, 224(sp)
    802000e8:	0e013e83          	ld	t4,224(sp)
    ld t3, 216(sp)
    802000ec:	0d813e03          	ld	t3,216(sp)
    ld s11, 208(sp)
    802000f0:	0d013d83          	ld	s11,208(sp)
    ld s10, 200(sp)
    802000f4:	0c813d03          	ld	s10,200(sp)
    ld s9, 192(sp)
    802000f8:	0c013c83          	ld	s9,192(sp)
    ld s8, 184(sp)
    802000fc:	0b813c03          	ld	s8,184(sp)
    ld s7, 176(sp)
    80200100:	0b013b83          	ld	s7,176(sp)
    ld s6, 168(sp)
    80200104:	0a813b03          	ld	s6,168(sp)
    ld s5, 160(sp)
    80200108:	0a013a83          	ld	s5,160(sp)
    ld s4, 152(sp)
    8020010c:	09813a03          	ld	s4,152(sp)
    ld s3, 144(sp)
    80200110:	09013983          	ld	s3,144(sp)
    ld s2, 136(sp)
    80200114:	08813903          	ld	s2,136(sp)
    ld a7, 128(sp)
    80200118:	08013883          	ld	a7,128(sp)
    ld a6, 120(sp)
    8020011c:	07813803          	ld	a6,120(sp)
    ld a5, 112(sp)
    80200120:	07013783          	ld	a5,112(sp)
    ld a4, 104(sp)
    80200124:	06813703          	ld	a4,104(sp)
    ld a3, 96(sp)
    80200128:	06013683          	ld	a3,96(sp)
    ld a2, 88(sp)
    8020012c:	05813603          	ld	a2,88(sp)
    ld a1, 80(sp)
    80200130:	05013583          	ld	a1,80(sp)
    ld a0, 72(sp)
    80200134:	04813503          	ld	a0,72(sp)
    ld s1, 64(sp)
    80200138:	04013483          	ld	s1,64(sp)
    ld s0, 56(sp)
    8020013c:	03813403          	ld	s0,56(sp)
    ld t2, 48(sp)
    80200140:	03013383          	ld	t2,48(sp)
    ld t1, 40(sp)
    80200144:	02813303          	ld	t1,40(sp)
    ld t0, 32(sp)
    80200148:	02013283          	ld	t0,32(sp)
    ld tp, 24(sp)
    8020014c:	01813203          	ld	tp,24(sp)
    ld gp, 16(sp)
    80200150:	01013183          	ld	gp,16(sp)
    ld ra, 0(sp)
    80200154:	00013083          	ld	ra,0(sp)
    ld sp, 8(sp)
    80200158:	00813103          	ld	sp,8(sp)

    # reset sp
    addi sp, sp, 33*8
    8020015c:	10810113          	addi	sp,sp,264

    # 4. return from trap
    sret
    80200160:	10200073          	sret

0000000080200164 <__dummy>:

__dummy:
    la t0, dummy # load the address of dummy into the t0 register
    80200164:	00003297          	auipc	t0,0x3
    80200168:	ec42b283          	ld	t0,-316(t0) # 80203028 <_GLOBAL_OFFSET_TABLE_+0x20>
    csrw sepc, t0
    8020016c:	14129073          	csrw	sepc,t0
    sret # the program will return to the address of dummy
    80200170:	10200073          	sret

0000000080200174 <__switch_to>:

__switch_to:
    # save states to prev process
    # a0 is the base address of task_struct prev, and the content of thread starts from 32(a0)
    sd ra, 32(a0)
    80200174:	02153023          	sd	ra,32(a0)
    sd sp, 40(a0)
    80200178:	02253423          	sd	sp,40(a0)
    sd s0, 48(a0)
    8020017c:	02853823          	sd	s0,48(a0)
    sd s1, 56(a0)
    80200180:	02953c23          	sd	s1,56(a0)
    sd s2, 64(a0)
    80200184:	05253023          	sd	s2,64(a0)
    sd s3, 72(a0)
    80200188:	05353423          	sd	s3,72(a0)
    sd s4, 80(a0)
    8020018c:	05453823          	sd	s4,80(a0)
    sd s5, 88(a0)
    80200190:	05553c23          	sd	s5,88(a0)
    sd s6, 96(a0)
    80200194:	07653023          	sd	s6,96(a0)
    sd s7, 104(a0)
    80200198:	07753423          	sd	s7,104(a0)
    sd s8, 112(a0)
    8020019c:	07853823          	sd	s8,112(a0)
    sd s9, 120(a0)
    802001a0:	07953c23          	sd	s9,120(a0)
    sd s10, 128(a0)
    802001a4:	09a53023          	sd	s10,128(a0)
    sd s11, 136(a0)
    802001a8:	09b53423          	sd	s11,136(a0)

    ld ra, 32(a1)
    802001ac:	0205b083          	ld	ra,32(a1)
    ld sp, 40(a1)
    802001b0:	0285b103          	ld	sp,40(a1)
    ld s0, 48(a1)
    802001b4:	0305b403          	ld	s0,48(a1)
    ld s1, 56(a1)
    802001b8:	0385b483          	ld	s1,56(a1)
    ld s2, 64(a1)
    802001bc:	0405b903          	ld	s2,64(a1)
    ld s3, 72(a1)
    802001c0:	0485b983          	ld	s3,72(a1)
    ld s4, 80(a1)
    802001c4:	0505ba03          	ld	s4,80(a1)
    ld s5, 88(a1)
    802001c8:	0585ba83          	ld	s5,88(a1)
    ld s6, 96(a1)
    802001cc:	0605bb03          	ld	s6,96(a1)
    ld s7, 104(a1)
    802001d0:	0685bb83          	ld	s7,104(a1)
    ld s8, 112(a1)
    802001d4:	0705bc03          	ld	s8,112(a1)
    ld s9, 120(a1)
    802001d8:	0785bc83          	ld	s9,120(a1)
    ld s10, 128(a1)
    802001dc:	0805bd03          	ld	s10,128(a1)
    ld s11, 136(a1)
    802001e0:	0885bd83          	ld	s11,136(a1)
    

    # restore state from next process


    802001e4:	00008067          	ret

00000000802001e8 <get_cycles>:
#include "sbi.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
    802001e8:	fe010113          	addi	sp,sp,-32
    802001ec:	00813c23          	sd	s0,24(sp)
    802001f0:	02010413          	addi	s0,sp,32
    uint64_t cycles;
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    __asm__ volatile(
    802001f4:	c01027f3          	rdtime	a5
    802001f8:	fef43423          	sd	a5,-24(s0)
        // read the time from mtime
        "rdtime %[cycles]"
        : [cycles] "=r" (cycles)
    );
    return cycles;
    802001fc:	fe843783          	ld	a5,-24(s0)
    // #error Unimplemented
}
    80200200:	00078513          	mv	a0,a5
    80200204:	01813403          	ld	s0,24(sp)
    80200208:	02010113          	addi	sp,sp,32
    8020020c:	00008067          	ret

0000000080200210 <clock_set_next_event>:

void clock_set_next_event() {
    80200210:	fe010113          	addi	sp,sp,-32
    80200214:	00113c23          	sd	ra,24(sp)
    80200218:	00813823          	sd	s0,16(sp)
    8020021c:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
    80200220:	fc9ff0ef          	jal	802001e8 <get_cycles>
    80200224:	00050713          	mv	a4,a0
    80200228:	00003797          	auipc	a5,0x3
    8020022c:	dd878793          	addi	a5,a5,-552 # 80203000 <TIMECLOCK>
    80200230:	0007b783          	ld	a5,0(a5)
    80200234:	00f707b3          	add	a5,a4,a5
    80200238:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
    sbi_set_timer(next);
    8020023c:	fe843503          	ld	a0,-24(s0)
    80200240:	688000ef          	jal	802008c8 <sbi_set_timer>
    // #error Unimplemented
    80200244:	00000013          	nop
    80200248:	01813083          	ld	ra,24(sp)
    8020024c:	01013403          	ld	s0,16(sp)
    80200250:	02010113          	addi	sp,sp,32
    80200254:	00008067          	ret

0000000080200258 <kalloc>:

struct {
    struct run *freelist;
} kmem;

void *kalloc() {
    80200258:	fe010113          	addi	sp,sp,-32
    8020025c:	00113c23          	sd	ra,24(sp)
    80200260:	00813823          	sd	s0,16(sp)
    80200264:	02010413          	addi	s0,sp,32
    struct run *r;

    r = kmem.freelist;
    80200268:	00005797          	auipc	a5,0x5
    8020026c:	d9878793          	addi	a5,a5,-616 # 80205000 <kmem>
    80200270:	0007b783          	ld	a5,0(a5)
    80200274:	fef43423          	sd	a5,-24(s0)
    kmem.freelist = r->next;
    80200278:	fe843783          	ld	a5,-24(s0)
    8020027c:	0007b703          	ld	a4,0(a5)
    80200280:	00005797          	auipc	a5,0x5
    80200284:	d8078793          	addi	a5,a5,-640 # 80205000 <kmem>
    80200288:	00e7b023          	sd	a4,0(a5)
    
    memset((void *)r, 0x0, PGSIZE);
    8020028c:	00001637          	lui	a2,0x1
    80200290:	00000593          	li	a1,0
    80200294:	fe843503          	ld	a0,-24(s0)
    80200298:	7e4010ef          	jal	80201a7c <memset>
    return (void *)r;
    8020029c:	fe843783          	ld	a5,-24(s0)
}
    802002a0:	00078513          	mv	a0,a5
    802002a4:	01813083          	ld	ra,24(sp)
    802002a8:	01013403          	ld	s0,16(sp)
    802002ac:	02010113          	addi	sp,sp,32
    802002b0:	00008067          	ret

00000000802002b4 <kfree>:

void kfree(void *addr) {
    802002b4:	fd010113          	addi	sp,sp,-48
    802002b8:	02113423          	sd	ra,40(sp)
    802002bc:	02813023          	sd	s0,32(sp)
    802002c0:	03010413          	addi	s0,sp,48
    802002c4:	fca43c23          	sd	a0,-40(s0)
    struct run *r;

    // PGSIZE align 
    *(uintptr_t *)&addr = (uintptr_t)addr & ~(PGSIZE - 1);
    802002c8:	fd843783          	ld	a5,-40(s0)
    802002cc:	00078693          	mv	a3,a5
    802002d0:	fd840793          	addi	a5,s0,-40
    802002d4:	fffff737          	lui	a4,0xfffff
    802002d8:	00e6f733          	and	a4,a3,a4
    802002dc:	00e7b023          	sd	a4,0(a5)

    memset(addr, 0x0, (uint64_t)PGSIZE);
    802002e0:	fd843783          	ld	a5,-40(s0)
    802002e4:	00001637          	lui	a2,0x1
    802002e8:	00000593          	li	a1,0
    802002ec:	00078513          	mv	a0,a5
    802002f0:	78c010ef          	jal	80201a7c <memset>

    r = (struct run *)addr;
    802002f4:	fd843783          	ld	a5,-40(s0)
    802002f8:	fef43423          	sd	a5,-24(s0)
    r->next = kmem.freelist;
    802002fc:	00005797          	auipc	a5,0x5
    80200300:	d0478793          	addi	a5,a5,-764 # 80205000 <kmem>
    80200304:	0007b703          	ld	a4,0(a5)
    80200308:	fe843783          	ld	a5,-24(s0)
    8020030c:	00e7b023          	sd	a4,0(a5)
    kmem.freelist = r;
    80200310:	00005797          	auipc	a5,0x5
    80200314:	cf078793          	addi	a5,a5,-784 # 80205000 <kmem>
    80200318:	fe843703          	ld	a4,-24(s0)
    8020031c:	00e7b023          	sd	a4,0(a5)

    return;
    80200320:	00000013          	nop
}
    80200324:	02813083          	ld	ra,40(sp)
    80200328:	02013403          	ld	s0,32(sp)
    8020032c:	03010113          	addi	sp,sp,48
    80200330:	00008067          	ret

0000000080200334 <kfreerange>:

void kfreerange(char *start, char *end) {
    80200334:	fd010113          	addi	sp,sp,-48
    80200338:	02113423          	sd	ra,40(sp)
    8020033c:	02813023          	sd	s0,32(sp)
    80200340:	03010413          	addi	s0,sp,48
    80200344:	fca43c23          	sd	a0,-40(s0)
    80200348:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uintptr_t)start);
    8020034c:	fd843703          	ld	a4,-40(s0)
    80200350:	000017b7          	lui	a5,0x1
    80200354:	fff78793          	addi	a5,a5,-1 # fff <_skernel-0x801ff001>
    80200358:	00f70733          	add	a4,a4,a5
    8020035c:	fffff7b7          	lui	a5,0xfffff
    80200360:	00f777b3          	and	a5,a4,a5
    80200364:	fef43423          	sd	a5,-24(s0)
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
    80200368:	01c0006f          	j	80200384 <kfreerange+0x50>
        kfree((void *)addr);
    8020036c:	fe843503          	ld	a0,-24(s0)
    80200370:	f45ff0ef          	jal	802002b4 <kfree>
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
    80200374:	fe843703          	ld	a4,-24(s0)
    80200378:	000017b7          	lui	a5,0x1
    8020037c:	00f707b3          	add	a5,a4,a5
    80200380:	fef43423          	sd	a5,-24(s0)
    80200384:	fe843703          	ld	a4,-24(s0)
    80200388:	000017b7          	lui	a5,0x1
    8020038c:	00f70733          	add	a4,a4,a5
    80200390:	fd043783          	ld	a5,-48(s0)
    80200394:	fce7fce3          	bgeu	a5,a4,8020036c <kfreerange+0x38>
    }
}
    80200398:	00000013          	nop
    8020039c:	00000013          	nop
    802003a0:	02813083          	ld	ra,40(sp)
    802003a4:	02013403          	ld	s0,32(sp)
    802003a8:	03010113          	addi	sp,sp,48
    802003ac:	00008067          	ret

00000000802003b0 <mm_init>:

void mm_init(void) {
    802003b0:	ff010113          	addi	sp,sp,-16
    802003b4:	00113423          	sd	ra,8(sp)
    802003b8:	00813023          	sd	s0,0(sp)
    802003bc:	01010413          	addi	s0,sp,16
    kfreerange(_ekernel, (char *)PHY_END);
    802003c0:	01100793          	li	a5,17
    802003c4:	01b79593          	slli	a1,a5,0x1b
    802003c8:	00003517          	auipc	a0,0x3
    802003cc:	c4853503          	ld	a0,-952(a0) # 80203010 <_GLOBAL_OFFSET_TABLE_+0x8>
    802003d0:	f65ff0ef          	jal	80200334 <kfreerange>
    printk("...mm_init done!\n");
    802003d4:	00002517          	auipc	a0,0x2
    802003d8:	c2c50513          	addi	a0,a0,-980 # 80202000 <_srodata>
    802003dc:	580010ef          	jal	8020195c <printk>
}
    802003e0:	00000013          	nop
    802003e4:	00813083          	ld	ra,8(sp)
    802003e8:	00013403          	ld	s0,0(sp)
    802003ec:	01010113          	addi	sp,sp,16
    802003f0:	00008067          	ret

00000000802003f4 <task_init>:

struct task_struct *idle;           // idle process
struct task_struct *current;        // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此

void task_init() {
    802003f4:	fe010113          	addi	sp,sp,-32
    802003f8:	00113c23          	sd	ra,24(sp)
    802003fc:	00813823          	sd	s0,16(sp)
    80200400:	02010413          	addi	s0,sp,32
    srand(2024);
    80200404:	7e800513          	li	a0,2024
    80200408:	5d4010ef          	jal	802019dc <srand>
    // 5. 将 current 和 task[0] 指向 idle

    /* YOUR CODE HERE */
    // mm_init();
    // allocate a physical page for idle
    idle = (struct task_struct*)kalloc();
    8020040c:	e4dff0ef          	jal	80200258 <kalloc>
    80200410:	00050713          	mv	a4,a0
    80200414:	00005797          	auipc	a5,0x5
    80200418:	bf478793          	addi	a5,a5,-1036 # 80205008 <idle>
    8020041c:	00e7b023          	sd	a4,0(a5)
    
    // set the state as TASK_RUNNING
    idle->state = TASK_RUNNING;
    80200420:	00005797          	auipc	a5,0x5
    80200424:	be878793          	addi	a5,a5,-1048 # 80205008 <idle>
    80200428:	0007b783          	ld	a5,0(a5)
    8020042c:	0007b023          	sd	zero,0(a5)

    // set the counter and priority
    idle->counter = idle->priority = 0;
    80200430:	00005797          	auipc	a5,0x5
    80200434:	bd878793          	addi	a5,a5,-1064 # 80205008 <idle>
    80200438:	0007b783          	ld	a5,0(a5)
    8020043c:	0007b823          	sd	zero,16(a5)
    80200440:	00005717          	auipc	a4,0x5
    80200444:	bc870713          	addi	a4,a4,-1080 # 80205008 <idle>
    80200448:	00073703          	ld	a4,0(a4)
    8020044c:	0107b783          	ld	a5,16(a5)
    80200450:	00f73423          	sd	a5,8(a4)

    // set the pid as 0
    idle->pid = 0;
    80200454:	00005797          	auipc	a5,0x5
    80200458:	bb478793          	addi	a5,a5,-1100 # 80205008 <idle>
    8020045c:	0007b783          	ld	a5,0(a5)
    80200460:	0007bc23          	sd	zero,24(a5)

    // set the current and task[0]
    current = idle;
    80200464:	00005797          	auipc	a5,0x5
    80200468:	ba478793          	addi	a5,a5,-1116 # 80205008 <idle>
    8020046c:	0007b703          	ld	a4,0(a5)
    80200470:	00005797          	auipc	a5,0x5
    80200474:	ba078793          	addi	a5,a5,-1120 # 80205010 <current>
    80200478:	00e7b023          	sd	a4,0(a5)
    task[0] = idle;
    8020047c:	00005797          	auipc	a5,0x5
    80200480:	b8c78793          	addi	a5,a5,-1140 # 80205008 <idle>
    80200484:	0007b703          	ld	a4,0(a5)
    80200488:	00005797          	auipc	a5,0x5
    8020048c:	b9078793          	addi	a5,a5,-1136 # 80205018 <task>
    80200490:	00e7b023          	sd	a4,0(a5)
    //     - ra 设置为 __dummy（见 4.2.2）的地址
    //     - sp 设置为该线程申请的物理页的高地址

    /* YOUR CODE HERE */
    // initialize all tasks as like idle
    for (int i = 1; i < NR_TASKS; i++) {
    80200494:	00100793          	li	a5,1
    80200498:	fef42623          	sw	a5,-20(s0)
    8020049c:	0a00006f          	j	8020053c <task_init+0x148>
        struct task_struct* new_task = (struct task_struct*)kalloc();
    802004a0:	db9ff0ef          	jal	80200258 <kalloc>
    802004a4:	fea43023          	sd	a0,-32(s0)
        new_task->state = TASK_RUNNING;
    802004a8:	fe043783          	ld	a5,-32(s0)
    802004ac:	0007b023          	sd	zero,0(a5)
        new_task->pid = i;
    802004b0:	fec42703          	lw	a4,-20(s0)
    802004b4:	fe043783          	ld	a5,-32(s0)
    802004b8:	00e7bc23          	sd	a4,24(a5)

        // set counter and priority using rand
        new_task->counter = 0;
    802004bc:	fe043783          	ld	a5,-32(s0)
    802004c0:	0007b423          	sd	zero,8(a5)
        new_task->priority = rand() % (PRIORITY_MAX-PRIORITY_MIN+1) + PRIORITY_MIN;
    802004c4:	55c010ef          	jal	80201a20 <rand>
    802004c8:	00050793          	mv	a5,a0
    802004cc:	00078713          	mv	a4,a5
    802004d0:	00a00793          	li	a5,10
    802004d4:	02f767bb          	remw	a5,a4,a5
    802004d8:	0007879b          	sext.w	a5,a5
    802004dc:	0017879b          	addiw	a5,a5,1
    802004e0:	0007879b          	sext.w	a5,a5
    802004e4:	00078713          	mv	a4,a5
    802004e8:	fe043783          	ld	a5,-32(s0)
    802004ec:	00e7b823          	sd	a4,16(a5)

        // set the ra and sp
        new_task->thread.ra = (uint64_t)__dummy;
    802004f0:	00003717          	auipc	a4,0x3
    802004f4:	b2873703          	ld	a4,-1240(a4) # 80203018 <_GLOBAL_OFFSET_TABLE_+0x10>
    802004f8:	fe043783          	ld	a5,-32(s0)
    802004fc:	02e7b023          	sd	a4,32(a5)
        new_task->thread.sp = (uint64_t)new_task + PGSIZE; // notice new_task is also an address of the struct (the bottom of the PAGE)
    80200500:	fe043703          	ld	a4,-32(s0)
    80200504:	000017b7          	lui	a5,0x1
    80200508:	00f70733          	add	a4,a4,a5
    8020050c:	fe043783          	ld	a5,-32(s0)
    80200510:	02e7b423          	sd	a4,40(a5) # 1028 <_skernel-0x801fefd8>
    
        task[i] = new_task;
    80200514:	00005717          	auipc	a4,0x5
    80200518:	b0470713          	addi	a4,a4,-1276 # 80205018 <task>
    8020051c:	fec42783          	lw	a5,-20(s0)
    80200520:	00379793          	slli	a5,a5,0x3
    80200524:	00f707b3          	add	a5,a4,a5
    80200528:	fe043703          	ld	a4,-32(s0)
    8020052c:	00e7b023          	sd	a4,0(a5)
    for (int i = 1; i < NR_TASKS; i++) {
    80200530:	fec42783          	lw	a5,-20(s0)
    80200534:	0017879b          	addiw	a5,a5,1
    80200538:	fef42623          	sw	a5,-20(s0)
    8020053c:	fec42783          	lw	a5,-20(s0)
    80200540:	0007871b          	sext.w	a4,a5
    80200544:	00400793          	li	a5,4
    80200548:	f4e7dce3          	bge	a5,a4,802004a0 <task_init+0xac>
    }

    printk("...task_init done!\n");
    8020054c:	00002517          	auipc	a0,0x2
    80200550:	acc50513          	addi	a0,a0,-1332 # 80202018 <_srodata+0x18>
    80200554:	408010ef          	jal	8020195c <printk>
}
    80200558:	00000013          	nop
    8020055c:	01813083          	ld	ra,24(sp)
    80200560:	01013403          	ld	s0,16(sp)
    80200564:	02010113          	addi	sp,sp,32
    80200568:	00008067          	ret

000000008020056c <dummy>:
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
    8020056c:	fd010113          	addi	sp,sp,-48
    80200570:	02113423          	sd	ra,40(sp)
    80200574:	02813023          	sd	s0,32(sp)
    80200578:	03010413          	addi	s0,sp,48
    uint64_t MOD = 1000000007;
    8020057c:	3b9ad7b7          	lui	a5,0x3b9ad
    80200580:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <_skernel-0x448535f9>
    80200584:	fcf43c23          	sd	a5,-40(s0)
    uint64_t auto_inc_local_var = 0;
    80200588:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1;
    8020058c:	fff00793          	li	a5,-1
    80200590:	fef42223          	sw	a5,-28(s0)
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
    80200594:	fe442783          	lw	a5,-28(s0)
    80200598:	0007871b          	sext.w	a4,a5
    8020059c:	fff00793          	li	a5,-1
    802005a0:	00f70e63          	beq	a4,a5,802005bc <dummy+0x50>
    802005a4:	00005797          	auipc	a5,0x5
    802005a8:	a6c78793          	addi	a5,a5,-1428 # 80205010 <current>
    802005ac:	0007b783          	ld	a5,0(a5)
    802005b0:	0087b703          	ld	a4,8(a5)
    802005b4:	fe442783          	lw	a5,-28(s0)
    802005b8:	fcf70ee3          	beq	a4,a5,80200594 <dummy+0x28>
    802005bc:	00005797          	auipc	a5,0x5
    802005c0:	a5478793          	addi	a5,a5,-1452 # 80205010 <current>
    802005c4:	0007b783          	ld	a5,0(a5)
    802005c8:	0087b783          	ld	a5,8(a5)
    802005cc:	fc0784e3          	beqz	a5,80200594 <dummy+0x28>
            if (current->counter == 1) {
    802005d0:	00005797          	auipc	a5,0x5
    802005d4:	a4078793          	addi	a5,a5,-1472 # 80205010 <current>
    802005d8:	0007b783          	ld	a5,0(a5)
    802005dc:	0087b703          	ld	a4,8(a5)
    802005e0:	00100793          	li	a5,1
    802005e4:	00f71e63          	bne	a4,a5,80200600 <dummy+0x94>
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
    802005e8:	00005797          	auipc	a5,0x5
    802005ec:	a2878793          	addi	a5,a5,-1496 # 80205010 <current>
    802005f0:	0007b783          	ld	a5,0(a5)
    802005f4:	0087b703          	ld	a4,8(a5)
    802005f8:	fff70713          	addi	a4,a4,-1
    802005fc:	00e7b423          	sd	a4,8(a5)
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
    80200600:	00005797          	auipc	a5,0x5
    80200604:	a1078793          	addi	a5,a5,-1520 # 80205010 <current>
    80200608:	0007b783          	ld	a5,0(a5)
    8020060c:	0087b783          	ld	a5,8(a5)
    80200610:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
    80200614:	fe843783          	ld	a5,-24(s0)
    80200618:	00178713          	addi	a4,a5,1
    8020061c:	fd843783          	ld	a5,-40(s0)
    80200620:	02f777b3          	remu	a5,a4,a5
    80200624:	fef43423          	sd	a5,-24(s0)
            printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid, auto_inc_local_var);
    80200628:	00005797          	auipc	a5,0x5
    8020062c:	9e878793          	addi	a5,a5,-1560 # 80205010 <current>
    80200630:	0007b783          	ld	a5,0(a5)
    80200634:	0187b783          	ld	a5,24(a5)
    80200638:	fe843603          	ld	a2,-24(s0)
    8020063c:	00078593          	mv	a1,a5
    80200640:	00002517          	auipc	a0,0x2
    80200644:	9f050513          	addi	a0,a0,-1552 # 80202030 <_srodata+0x30>
    80200648:	314010ef          	jal	8020195c <printk>
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
    8020064c:	f49ff06f          	j	80200594 <dummy+0x28>

0000000080200650 <switch_to>:

// 外部的处理线程切换的函数，在entry.S中实现
extern void __switch_to(struct task_struct *prev, struct task_struct *next);

/* 线程切换入口函数 */
void switch_to(struct task_struct *next) {
    80200650:	fe010113          	addi	sp,sp,-32
    80200654:	00113c23          	sd	ra,24(sp)
    80200658:	00813823          	sd	s0,16(sp)
    8020065c:	02010413          	addi	s0,sp,32
    80200660:	fea43423          	sd	a0,-24(s0)
    // check if the current task is the same as the next one using their unique pid
    if (next->pid != current->pid) {
    80200664:	fe843783          	ld	a5,-24(s0)
    80200668:	0187b703          	ld	a4,24(a5)
    8020066c:	00005797          	auipc	a5,0x5
    80200670:	9a478793          	addi	a5,a5,-1628 # 80205010 <current>
    80200674:	0007b783          	ld	a5,0(a5)
    80200678:	0187b783          	ld	a5,24(a5)
    8020067c:	00f70e63          	beq	a4,a5,80200698 <switch_to+0x48>
        // if they are not the same, call __switch_to
        __switch_to(current, next);
    80200680:	00005797          	auipc	a5,0x5
    80200684:	99078793          	addi	a5,a5,-1648 # 80205010 <current>
    80200688:	0007b783          	ld	a5,0(a5)
    8020068c:	fe843583          	ld	a1,-24(s0)
    80200690:	00078513          	mv	a0,a5
    80200694:	ae1ff0ef          	jal	80200174 <__switch_to>
    }
    80200698:	00000013          	nop
    8020069c:	01813083          	ld	ra,24(sp)
    802006a0:	01013403          	ld	s0,16(sp)
    802006a4:	02010113          	addi	sp,sp,32
    802006a8:	00008067          	ret

00000000802006ac <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    802006ac:	f8010113          	addi	sp,sp,-128
    802006b0:	06813c23          	sd	s0,120(sp)
    802006b4:	06913823          	sd	s1,112(sp)
    802006b8:	07213423          	sd	s2,104(sp)
    802006bc:	07313023          	sd	s3,96(sp)
    802006c0:	08010413          	addi	s0,sp,128
    802006c4:	faa43c23          	sd	a0,-72(s0)
    802006c8:	fab43823          	sd	a1,-80(s0)
    802006cc:	fac43423          	sd	a2,-88(s0)
    802006d0:	fad43023          	sd	a3,-96(s0)
    802006d4:	f8e43c23          	sd	a4,-104(s0)
    802006d8:	f8f43823          	sd	a5,-112(s0)
    802006dc:	f9043423          	sd	a6,-120(s0)
    802006e0:	f9143023          	sd	a7,-128(s0)
    // #error Unimplemented
    struct sbiret ret;

    __asm__ volatile (
    802006e4:	fb843e03          	ld	t3,-72(s0)
    802006e8:	fb043e83          	ld	t4,-80(s0)
    802006ec:	f8043f03          	ld	t5,-128(s0)
    802006f0:	f8843f83          	ld	t6,-120(s0)
    802006f4:	f9043283          	ld	t0,-112(s0)
    802006f8:	f9843483          	ld	s1,-104(s0)
    802006fc:	fa043903          	ld	s2,-96(s0)
    80200700:	fa843983          	ld	s3,-88(s0)
    80200704:	000e0893          	mv	a7,t3
    80200708:	000e8813          	mv	a6,t4
    8020070c:	000f0793          	mv	a5,t5
    80200710:	000f8713          	mv	a4,t6
    80200714:	00028693          	mv	a3,t0
    80200718:	00048613          	mv	a2,s1
    8020071c:	00090593          	mv	a1,s2
    80200720:	00098513          	mv	a0,s3
    80200724:	00000073          	ecall
    80200728:	00050e93          	mv	t4,a0
    8020072c:	00058e13          	mv	t3,a1
    80200730:	fdd43023          	sd	t4,-64(s0)
    80200734:	fdc43423          	sd	t3,-56(s0)
        "mv %[ret_val], a1\n"
        : [error] "=r" (ret.error), [ret_val] "=r" (ret.value)
        : [eid] "r" (eid), [fid] "r" (fid), [arg5] "r" (arg5), [arg4] "r" (arg4), [arg3] "r" (arg3), [arg2] "r" (arg2), [arg1] "r" (arg1), [arg0] "r" (arg0)
        : "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "memory"
    );
    return ret;
    80200738:	fc043783          	ld	a5,-64(s0)
    8020073c:	fcf43823          	sd	a5,-48(s0)
    80200740:	fc843783          	ld	a5,-56(s0)
    80200744:	fcf43c23          	sd	a5,-40(s0)
    80200748:	fd043703          	ld	a4,-48(s0)
    8020074c:	fd843783          	ld	a5,-40(s0)
    80200750:	00070313          	mv	t1,a4
    80200754:	00078393          	mv	t2,a5
    80200758:	00030713          	mv	a4,t1
    8020075c:	00038793          	mv	a5,t2
}
    80200760:	00070513          	mv	a0,a4
    80200764:	00078593          	mv	a1,a5
    80200768:	07813403          	ld	s0,120(sp)
    8020076c:	07013483          	ld	s1,112(sp)
    80200770:	06813903          	ld	s2,104(sp)
    80200774:	06013983          	ld	s3,96(sp)
    80200778:	08010113          	addi	sp,sp,128
    8020077c:	00008067          	ret

0000000080200780 <sbi_debug_console_write_byte>:

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    80200780:	fb010113          	addi	sp,sp,-80
    80200784:	04113423          	sd	ra,72(sp)
    80200788:	04813023          	sd	s0,64(sp)
    8020078c:	03213c23          	sd	s2,56(sp)
    80200790:	03313823          	sd	s3,48(sp)
    80200794:	05010413          	addi	s0,sp,80
    80200798:	00050793          	mv	a5,a0
    8020079c:	faf40fa3          	sb	a5,-65(s0)
    // #error Unimplemented
    // set eid and fid
    uint64_t sbi_debug_console_write_byte_eid = 0x4442434E;
    802007a0:	444247b7          	lui	a5,0x44424
    802007a4:	34e78793          	addi	a5,a5,846 # 4442434e <_skernel-0x3bddbcb2>
    802007a8:	fcf43c23          	sd	a5,-40(s0)
    uint64_t sbi_debug_console_write_byte_fid = 2;
    802007ac:	00200793          	li	a5,2
    802007b0:	fcf43823          	sd	a5,-48(s0)
    return sbi_ecall(sbi_debug_console_write_byte_eid, sbi_debug_console_write_byte_fid, byte, 0, 0, 0, 0, 0);
    802007b4:	fbf44603          	lbu	a2,-65(s0)
    802007b8:	00000893          	li	a7,0
    802007bc:	00000813          	li	a6,0
    802007c0:	00000793          	li	a5,0
    802007c4:	00000713          	li	a4,0
    802007c8:	00000693          	li	a3,0
    802007cc:	fd043583          	ld	a1,-48(s0)
    802007d0:	fd843503          	ld	a0,-40(s0)
    802007d4:	ed9ff0ef          	jal	802006ac <sbi_ecall>
    802007d8:	00050713          	mv	a4,a0
    802007dc:	00058793          	mv	a5,a1
    802007e0:	fce43023          	sd	a4,-64(s0)
    802007e4:	fcf43423          	sd	a5,-56(s0)
    802007e8:	fc043703          	ld	a4,-64(s0)
    802007ec:	fc843783          	ld	a5,-56(s0)
    802007f0:	00070913          	mv	s2,a4
    802007f4:	00078993          	mv	s3,a5
    802007f8:	00090713          	mv	a4,s2
    802007fc:	00098793          	mv	a5,s3

}
    80200800:	00070513          	mv	a0,a4
    80200804:	00078593          	mv	a1,a5
    80200808:	04813083          	ld	ra,72(sp)
    8020080c:	04013403          	ld	s0,64(sp)
    80200810:	03813903          	ld	s2,56(sp)
    80200814:	03013983          	ld	s3,48(sp)
    80200818:	05010113          	addi	sp,sp,80
    8020081c:	00008067          	ret

0000000080200820 <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    80200820:	fb010113          	addi	sp,sp,-80
    80200824:	04113423          	sd	ra,72(sp)
    80200828:	04813023          	sd	s0,64(sp)
    8020082c:	03213c23          	sd	s2,56(sp)
    80200830:	03313823          	sd	s3,48(sp)
    80200834:	05010413          	addi	s0,sp,80
    80200838:	00050793          	mv	a5,a0
    8020083c:	00058713          	mv	a4,a1
    80200840:	faf42e23          	sw	a5,-68(s0)
    80200844:	00070793          	mv	a5,a4
    80200848:	faf42c23          	sw	a5,-72(s0)
    // #error Unimplemented
    // set eid and fid
    uint64_t sbi_system_reset_eid = 0x53525354;
    8020084c:	535257b7          	lui	a5,0x53525
    80200850:	35478793          	addi	a5,a5,852 # 53525354 <_skernel-0x2ccdacac>
    80200854:	fcf43c23          	sd	a5,-40(s0)
    uint64_t sbi_system_reset_fid = 0;
    80200858:	fc043823          	sd	zero,-48(s0)
    return sbi_ecall(sbi_system_reset_eid, sbi_system_reset_fid, reset_type, reset_reason, 0, 0, 0, 0);
    8020085c:	fbc46603          	lwu	a2,-68(s0)
    80200860:	fb846683          	lwu	a3,-72(s0)
    80200864:	00000893          	li	a7,0
    80200868:	00000813          	li	a6,0
    8020086c:	00000793          	li	a5,0
    80200870:	00000713          	li	a4,0
    80200874:	fd043583          	ld	a1,-48(s0)
    80200878:	fd843503          	ld	a0,-40(s0)
    8020087c:	e31ff0ef          	jal	802006ac <sbi_ecall>
    80200880:	00050713          	mv	a4,a0
    80200884:	00058793          	mv	a5,a1
    80200888:	fce43023          	sd	a4,-64(s0)
    8020088c:	fcf43423          	sd	a5,-56(s0)
    80200890:	fc043703          	ld	a4,-64(s0)
    80200894:	fc843783          	ld	a5,-56(s0)
    80200898:	00070913          	mv	s2,a4
    8020089c:	00078993          	mv	s3,a5
    802008a0:	00090713          	mv	a4,s2
    802008a4:	00098793          	mv	a5,s3
}
    802008a8:	00070513          	mv	a0,a4
    802008ac:	00078593          	mv	a1,a5
    802008b0:	04813083          	ld	ra,72(sp)
    802008b4:	04013403          	ld	s0,64(sp)
    802008b8:	03813903          	ld	s2,56(sp)
    802008bc:	03013983          	ld	s3,48(sp)
    802008c0:	05010113          	addi	sp,sp,80
    802008c4:	00008067          	ret

00000000802008c8 <sbi_set_timer>:


struct sbiret sbi_set_timer(uint64_t stime_value) {
    802008c8:	fb010113          	addi	sp,sp,-80
    802008cc:	04113423          	sd	ra,72(sp)
    802008d0:	04813023          	sd	s0,64(sp)
    802008d4:	03213c23          	sd	s2,56(sp)
    802008d8:	03313823          	sd	s3,48(sp)
    802008dc:	05010413          	addi	s0,sp,80
    802008e0:	faa43c23          	sd	a0,-72(s0)
    // set eid and fid
    uint64_t sbi_set_timer_eid = 0x54494D45;
    802008e4:	544957b7          	lui	a5,0x54495
    802008e8:	d4578793          	addi	a5,a5,-699 # 54494d45 <_skernel-0x2bd6b2bb>
    802008ec:	fcf43c23          	sd	a5,-40(s0)
    uint64_t sbi_set_timer_fid = 0;
    802008f0:	fc043823          	sd	zero,-48(s0)
    return sbi_ecall(sbi_set_timer_eid, sbi_set_timer_fid, stime_value, 0, 0, 0, 0, 0);
    802008f4:	00000893          	li	a7,0
    802008f8:	00000813          	li	a6,0
    802008fc:	00000793          	li	a5,0
    80200900:	00000713          	li	a4,0
    80200904:	00000693          	li	a3,0
    80200908:	fb843603          	ld	a2,-72(s0)
    8020090c:	fd043583          	ld	a1,-48(s0)
    80200910:	fd843503          	ld	a0,-40(s0)
    80200914:	d99ff0ef          	jal	802006ac <sbi_ecall>
    80200918:	00050713          	mv	a4,a0
    8020091c:	00058793          	mv	a5,a1
    80200920:	fce43023          	sd	a4,-64(s0)
    80200924:	fcf43423          	sd	a5,-56(s0)
    80200928:	fc043703          	ld	a4,-64(s0)
    8020092c:	fc843783          	ld	a5,-56(s0)
    80200930:	00070913          	mv	s2,a4
    80200934:	00078993          	mv	s3,a5
    80200938:	00090713          	mv	a4,s2
    8020093c:	00098793          	mv	a5,s3
    80200940:	00070513          	mv	a0,a4
    80200944:	00078593          	mv	a1,a5
    80200948:	04813083          	ld	ra,72(sp)
    8020094c:	04013403          	ld	s0,64(sp)
    80200950:	03813903          	ld	s2,56(sp)
    80200954:	03013983          	ld	s3,48(sp)
    80200958:	05010113          	addi	sp,sp,80
    8020095c:	00008067          	ret

0000000080200960 <trap_handler>:
#include "stdint.h"
#include "printk.h"
#include "defs.h"
extern void clock_set_next_event(void);

void trap_handler(uint64_t scause, uint64_t sepc) {
    80200960:	fc010113          	addi	sp,sp,-64
    80200964:	02113c23          	sd	ra,56(sp)
    80200968:	02813823          	sd	s0,48(sp)
    8020096c:	04010413          	addi	s0,sp,64
    80200970:	fca43423          	sd	a0,-56(s0)
    80200974:	fcb43023          	sd	a1,-64(s0)

    // printk("in trap, the value pf sstatus is %llx \n", csr_read(sstatus));

    // 通过 `scause` 判断 trap 类型
    bool interrupt = (scause >> 63);
    80200978:	fc843783          	ld	a5,-56(s0)
    8020097c:	03f7d793          	srli	a5,a5,0x3f
    80200980:	00f037b3          	snez	a5,a5
    80200984:	fef407a3          	sb	a5,-17(s0)
    
    // 如果是 interrupt 判断是否是 timer interrupt
    uint64_t exception_code = scause & 0x7fffffff;
    80200988:	fc843703          	ld	a4,-56(s0)
    8020098c:	800007b7          	lui	a5,0x80000
    80200990:	fff7c793          	not	a5,a5
    80200994:	00f777b3          	and	a5,a4,a5
    80200998:	fef43023          	sd	a5,-32(s0)
    bool timer_interrupt = interrupt & (exception_code == 5);
    8020099c:	fef44783          	lbu	a5,-17(s0)
    802009a0:	0007871b          	sext.w	a4,a5
    802009a4:	fe043783          	ld	a5,-32(s0)
    802009a8:	ffb78793          	addi	a5,a5,-5 # ffffffff7ffffffb <_ebss+0xfffffffeffdfafb3>
    802009ac:	0017b793          	seqz	a5,a5
    802009b0:	0ff7f793          	zext.b	a5,a5
    802009b4:	0007879b          	sext.w	a5,a5
    802009b8:	00f777b3          	and	a5,a4,a5
    802009bc:	0007879b          	sext.w	a5,a5
    802009c0:	00f037b3          	snez	a5,a5
    802009c4:	fcf40fa3          	sb	a5,-33(s0)
    
    // 如果是 timer interrupt 则打印输出相关信息，并通过 `clock_set_next_event()` 设置下一次时钟中断
    // printk("interrupt is %d, exception_code is %d\n", interrupt, exception_code);
    if (timer_interrupt) {
    802009c8:	fdf44783          	lbu	a5,-33(s0)
    802009cc:	0ff7f793          	zext.b	a5,a5
    802009d0:	00078c63          	beqz	a5,802009e8 <trap_handler+0x88>
        printk("[S] Supervisor Mode Timer Interrupt\n");
    802009d4:	00001517          	auipc	a0,0x1
    802009d8:	68c50513          	addi	a0,a0,1676 # 80202060 <_srodata+0x60>
    802009dc:	781000ef          	jal	8020195c <printk>
    
        // `clock_set_next_event()` 见 4.3.4 节
        clock_set_next_event();
    802009e0:	831ff0ef          	jal	80200210 <clock_set_next_event>
        // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试
        printk("%llx, %d, %llx, %d\n", scause, interrupt, exception_code, timer_interrupt);
        // printk("test: 802005a8 >> 63 = %llx\n", 0x802005a8 >> 63);
    }
    // #error Unimplemented
    802009e4:	02c0006f          	j	80200a10 <trap_handler+0xb0>
        printk("%llx, %d, %llx, %d\n", scause, interrupt, exception_code, timer_interrupt);
    802009e8:	fef44783          	lbu	a5,-17(s0)
    802009ec:	0007879b          	sext.w	a5,a5
    802009f0:	fdf44703          	lbu	a4,-33(s0)
    802009f4:	0007071b          	sext.w	a4,a4
    802009f8:	fe043683          	ld	a3,-32(s0)
    802009fc:	00078613          	mv	a2,a5
    80200a00:	fc843583          	ld	a1,-56(s0)
    80200a04:	00001517          	auipc	a0,0x1
    80200a08:	68450513          	addi	a0,a0,1668 # 80202088 <_srodata+0x88>
    80200a0c:	751000ef          	jal	8020195c <printk>
    80200a10:	00000013          	nop
    80200a14:	03813083          	ld	ra,56(sp)
    80200a18:	03013403          	ld	s0,48(sp)
    80200a1c:	04010113          	addi	sp,sp,64
    80200a20:	00008067          	ret

0000000080200a24 <start_kernel>:
#include "printk.h"
#include "defs.h"
extern void test();

int start_kernel() {
    80200a24:	fe010113          	addi	sp,sp,-32
    80200a28:	00113c23          	sd	ra,24(sp)
    80200a2c:	00813823          	sd	s0,16(sp)
    80200a30:	02010413          	addi	s0,sp,32
    printk("2024");
    80200a34:	00001517          	auipc	a0,0x1
    80200a38:	66c50513          	addi	a0,a0,1644 # 802020a0 <_srodata+0xa0>
    80200a3c:	721000ef          	jal	8020195c <printk>
    printk(" ZJU Operating System\n");
    80200a40:	00001517          	auipc	a0,0x1
    80200a44:	66850513          	addi	a0,a0,1640 # 802020a8 <_srodata+0xa8>
    80200a48:	715000ef          	jal	8020195c <printk>

    // printk("before writing into the sscratch, the value is 0x%llx\n", csr_read(sscratch));
    csr_write(sscratch, 0x1);
    80200a4c:	00100793          	li	a5,1
    80200a50:	fef43423          	sd	a5,-24(s0)
    80200a54:	fe843783          	ld	a5,-24(s0)
    80200a58:	14079073          	csrw	sscratch,a5
    // printk("after writing into the sscratch, the value is 0x%llx\n", csr_read(sscratch));

    test();
    80200a5c:	01c000ef          	jal	80200a78 <test>
    return 0;
    80200a60:	00000793          	li	a5,0
}
    80200a64:	00078513          	mv	a0,a5
    80200a68:	01813083          	ld	ra,24(sp)
    80200a6c:	01013403          	ld	s0,16(sp)
    80200a70:	02010113          	addi	sp,sp,32
    80200a74:	00008067          	ret

0000000080200a78 <test>:
#include "printk.h"
#include "defs.h"
void test() {
    80200a78:	fe010113          	addi	sp,sp,-32
    80200a7c:	00113c23          	sd	ra,24(sp)
    80200a80:	00813823          	sd	s0,16(sp)
    80200a84:	02010413          	addi	s0,sp,32
    int i = 0;
    80200a88:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
    80200a8c:	fec42783          	lw	a5,-20(s0)
    80200a90:	0017879b          	addiw	a5,a5,1
    80200a94:	fef42623          	sw	a5,-20(s0)
    80200a98:	fec42783          	lw	a5,-20(s0)
    80200a9c:	00078713          	mv	a4,a5
    80200aa0:	05f5e7b7          	lui	a5,0x5f5e
    80200aa4:	1007879b          	addiw	a5,a5,256 # 5f5e100 <_skernel-0x7a2a1f00>
    80200aa8:	02f767bb          	remw	a5,a4,a5
    80200aac:	0007879b          	sext.w	a5,a5
    80200ab0:	fc079ee3          	bnez	a5,80200a8c <test+0x14>
            // printk("in test, the value of sstatus is %llx \n", csr_read(sstatus));
            printk("kernel is running!\n");
    80200ab4:	00001517          	auipc	a0,0x1
    80200ab8:	60c50513          	addi	a0,a0,1548 # 802020c0 <_srodata+0xc0>
    80200abc:	6a1000ef          	jal	8020195c <printk>
            i = 0;
    80200ac0:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
    80200ac4:	fc9ff06f          	j	80200a8c <test+0x14>

0000000080200ac8 <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
    80200ac8:	fe010113          	addi	sp,sp,-32
    80200acc:	00113c23          	sd	ra,24(sp)
    80200ad0:	00813823          	sd	s0,16(sp)
    80200ad4:	02010413          	addi	s0,sp,32
    80200ad8:	00050793          	mv	a5,a0
    80200adc:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
    80200ae0:	fec42783          	lw	a5,-20(s0)
    80200ae4:	0ff7f793          	zext.b	a5,a5
    80200ae8:	00078513          	mv	a0,a5
    80200aec:	c95ff0ef          	jal	80200780 <sbi_debug_console_write_byte>
    return (char)c;
    80200af0:	fec42783          	lw	a5,-20(s0)
    80200af4:	0ff7f793          	zext.b	a5,a5
    80200af8:	0007879b          	sext.w	a5,a5
}
    80200afc:	00078513          	mv	a0,a5
    80200b00:	01813083          	ld	ra,24(sp)
    80200b04:	01013403          	ld	s0,16(sp)
    80200b08:	02010113          	addi	sp,sp,32
    80200b0c:	00008067          	ret

0000000080200b10 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
    80200b10:	fe010113          	addi	sp,sp,-32
    80200b14:	00813c23          	sd	s0,24(sp)
    80200b18:	02010413          	addi	s0,sp,32
    80200b1c:	00050793          	mv	a5,a0
    80200b20:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
    80200b24:	fec42783          	lw	a5,-20(s0)
    80200b28:	0007871b          	sext.w	a4,a5
    80200b2c:	02000793          	li	a5,32
    80200b30:	02f70263          	beq	a4,a5,80200b54 <isspace+0x44>
    80200b34:	fec42783          	lw	a5,-20(s0)
    80200b38:	0007871b          	sext.w	a4,a5
    80200b3c:	00800793          	li	a5,8
    80200b40:	00e7de63          	bge	a5,a4,80200b5c <isspace+0x4c>
    80200b44:	fec42783          	lw	a5,-20(s0)
    80200b48:	0007871b          	sext.w	a4,a5
    80200b4c:	00d00793          	li	a5,13
    80200b50:	00e7c663          	blt	a5,a4,80200b5c <isspace+0x4c>
    80200b54:	00100793          	li	a5,1
    80200b58:	0080006f          	j	80200b60 <isspace+0x50>
    80200b5c:	00000793          	li	a5,0
}
    80200b60:	00078513          	mv	a0,a5
    80200b64:	01813403          	ld	s0,24(sp)
    80200b68:	02010113          	addi	sp,sp,32
    80200b6c:	00008067          	ret

0000000080200b70 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
    80200b70:	fb010113          	addi	sp,sp,-80
    80200b74:	04113423          	sd	ra,72(sp)
    80200b78:	04813023          	sd	s0,64(sp)
    80200b7c:	05010413          	addi	s0,sp,80
    80200b80:	fca43423          	sd	a0,-56(s0)
    80200b84:	fcb43023          	sd	a1,-64(s0)
    80200b88:	00060793          	mv	a5,a2
    80200b8c:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
    80200b90:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
    80200b94:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
    80200b98:	fc843783          	ld	a5,-56(s0)
    80200b9c:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
    80200ba0:	0100006f          	j	80200bb0 <strtol+0x40>
        p++;
    80200ba4:	fd843783          	ld	a5,-40(s0)
    80200ba8:	00178793          	addi	a5,a5,1
    80200bac:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
    80200bb0:	fd843783          	ld	a5,-40(s0)
    80200bb4:	0007c783          	lbu	a5,0(a5)
    80200bb8:	0007879b          	sext.w	a5,a5
    80200bbc:	00078513          	mv	a0,a5
    80200bc0:	f51ff0ef          	jal	80200b10 <isspace>
    80200bc4:	00050793          	mv	a5,a0
    80200bc8:	fc079ee3          	bnez	a5,80200ba4 <strtol+0x34>
    }

    if (*p == '-') {
    80200bcc:	fd843783          	ld	a5,-40(s0)
    80200bd0:	0007c783          	lbu	a5,0(a5)
    80200bd4:	00078713          	mv	a4,a5
    80200bd8:	02d00793          	li	a5,45
    80200bdc:	00f71e63          	bne	a4,a5,80200bf8 <strtol+0x88>
        neg = true;
    80200be0:	00100793          	li	a5,1
    80200be4:	fef403a3          	sb	a5,-25(s0)
        p++;
    80200be8:	fd843783          	ld	a5,-40(s0)
    80200bec:	00178793          	addi	a5,a5,1
    80200bf0:	fcf43c23          	sd	a5,-40(s0)
    80200bf4:	0240006f          	j	80200c18 <strtol+0xa8>
    } else if (*p == '+') {
    80200bf8:	fd843783          	ld	a5,-40(s0)
    80200bfc:	0007c783          	lbu	a5,0(a5)
    80200c00:	00078713          	mv	a4,a5
    80200c04:	02b00793          	li	a5,43
    80200c08:	00f71863          	bne	a4,a5,80200c18 <strtol+0xa8>
        p++;
    80200c0c:	fd843783          	ld	a5,-40(s0)
    80200c10:	00178793          	addi	a5,a5,1
    80200c14:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
    80200c18:	fbc42783          	lw	a5,-68(s0)
    80200c1c:	0007879b          	sext.w	a5,a5
    80200c20:	06079c63          	bnez	a5,80200c98 <strtol+0x128>
        if (*p == '0') {
    80200c24:	fd843783          	ld	a5,-40(s0)
    80200c28:	0007c783          	lbu	a5,0(a5)
    80200c2c:	00078713          	mv	a4,a5
    80200c30:	03000793          	li	a5,48
    80200c34:	04f71e63          	bne	a4,a5,80200c90 <strtol+0x120>
            p++;
    80200c38:	fd843783          	ld	a5,-40(s0)
    80200c3c:	00178793          	addi	a5,a5,1
    80200c40:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
    80200c44:	fd843783          	ld	a5,-40(s0)
    80200c48:	0007c783          	lbu	a5,0(a5)
    80200c4c:	00078713          	mv	a4,a5
    80200c50:	07800793          	li	a5,120
    80200c54:	00f70c63          	beq	a4,a5,80200c6c <strtol+0xfc>
    80200c58:	fd843783          	ld	a5,-40(s0)
    80200c5c:	0007c783          	lbu	a5,0(a5)
    80200c60:	00078713          	mv	a4,a5
    80200c64:	05800793          	li	a5,88
    80200c68:	00f71e63          	bne	a4,a5,80200c84 <strtol+0x114>
                base = 16;
    80200c6c:	01000793          	li	a5,16
    80200c70:	faf42e23          	sw	a5,-68(s0)
                p++;
    80200c74:	fd843783          	ld	a5,-40(s0)
    80200c78:	00178793          	addi	a5,a5,1
    80200c7c:	fcf43c23          	sd	a5,-40(s0)
    80200c80:	0180006f          	j	80200c98 <strtol+0x128>
            } else {
                base = 8;
    80200c84:	00800793          	li	a5,8
    80200c88:	faf42e23          	sw	a5,-68(s0)
    80200c8c:	00c0006f          	j	80200c98 <strtol+0x128>
            }
        } else {
            base = 10;
    80200c90:	00a00793          	li	a5,10
    80200c94:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
    80200c98:	fd843783          	ld	a5,-40(s0)
    80200c9c:	0007c783          	lbu	a5,0(a5)
    80200ca0:	00078713          	mv	a4,a5
    80200ca4:	02f00793          	li	a5,47
    80200ca8:	02e7f863          	bgeu	a5,a4,80200cd8 <strtol+0x168>
    80200cac:	fd843783          	ld	a5,-40(s0)
    80200cb0:	0007c783          	lbu	a5,0(a5)
    80200cb4:	00078713          	mv	a4,a5
    80200cb8:	03900793          	li	a5,57
    80200cbc:	00e7ee63          	bltu	a5,a4,80200cd8 <strtol+0x168>
            digit = *p - '0';
    80200cc0:	fd843783          	ld	a5,-40(s0)
    80200cc4:	0007c783          	lbu	a5,0(a5)
    80200cc8:	0007879b          	sext.w	a5,a5
    80200ccc:	fd07879b          	addiw	a5,a5,-48
    80200cd0:	fcf42a23          	sw	a5,-44(s0)
    80200cd4:	0800006f          	j	80200d54 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
    80200cd8:	fd843783          	ld	a5,-40(s0)
    80200cdc:	0007c783          	lbu	a5,0(a5)
    80200ce0:	00078713          	mv	a4,a5
    80200ce4:	06000793          	li	a5,96
    80200ce8:	02e7f863          	bgeu	a5,a4,80200d18 <strtol+0x1a8>
    80200cec:	fd843783          	ld	a5,-40(s0)
    80200cf0:	0007c783          	lbu	a5,0(a5)
    80200cf4:	00078713          	mv	a4,a5
    80200cf8:	07a00793          	li	a5,122
    80200cfc:	00e7ee63          	bltu	a5,a4,80200d18 <strtol+0x1a8>
            digit = *p - ('a' - 10);
    80200d00:	fd843783          	ld	a5,-40(s0)
    80200d04:	0007c783          	lbu	a5,0(a5)
    80200d08:	0007879b          	sext.w	a5,a5
    80200d0c:	fa97879b          	addiw	a5,a5,-87
    80200d10:	fcf42a23          	sw	a5,-44(s0)
    80200d14:	0400006f          	j	80200d54 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
    80200d18:	fd843783          	ld	a5,-40(s0)
    80200d1c:	0007c783          	lbu	a5,0(a5)
    80200d20:	00078713          	mv	a4,a5
    80200d24:	04000793          	li	a5,64
    80200d28:	06e7f863          	bgeu	a5,a4,80200d98 <strtol+0x228>
    80200d2c:	fd843783          	ld	a5,-40(s0)
    80200d30:	0007c783          	lbu	a5,0(a5)
    80200d34:	00078713          	mv	a4,a5
    80200d38:	05a00793          	li	a5,90
    80200d3c:	04e7ee63          	bltu	a5,a4,80200d98 <strtol+0x228>
            digit = *p - ('A' - 10);
    80200d40:	fd843783          	ld	a5,-40(s0)
    80200d44:	0007c783          	lbu	a5,0(a5)
    80200d48:	0007879b          	sext.w	a5,a5
    80200d4c:	fc97879b          	addiw	a5,a5,-55
    80200d50:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
    80200d54:	fd442783          	lw	a5,-44(s0)
    80200d58:	00078713          	mv	a4,a5
    80200d5c:	fbc42783          	lw	a5,-68(s0)
    80200d60:	0007071b          	sext.w	a4,a4
    80200d64:	0007879b          	sext.w	a5,a5
    80200d68:	02f75663          	bge	a4,a5,80200d94 <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
    80200d6c:	fbc42703          	lw	a4,-68(s0)
    80200d70:	fe843783          	ld	a5,-24(s0)
    80200d74:	02f70733          	mul	a4,a4,a5
    80200d78:	fd442783          	lw	a5,-44(s0)
    80200d7c:	00f707b3          	add	a5,a4,a5
    80200d80:	fef43423          	sd	a5,-24(s0)
        p++;
    80200d84:	fd843783          	ld	a5,-40(s0)
    80200d88:	00178793          	addi	a5,a5,1
    80200d8c:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
    80200d90:	f09ff06f          	j	80200c98 <strtol+0x128>
            break;
    80200d94:	00000013          	nop
    }

    if (endptr) {
    80200d98:	fc043783          	ld	a5,-64(s0)
    80200d9c:	00078863          	beqz	a5,80200dac <strtol+0x23c>
        *endptr = (char *)p;
    80200da0:	fc043783          	ld	a5,-64(s0)
    80200da4:	fd843703          	ld	a4,-40(s0)
    80200da8:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
    80200dac:	fe744783          	lbu	a5,-25(s0)
    80200db0:	0ff7f793          	zext.b	a5,a5
    80200db4:	00078863          	beqz	a5,80200dc4 <strtol+0x254>
    80200db8:	fe843783          	ld	a5,-24(s0)
    80200dbc:	40f007b3          	neg	a5,a5
    80200dc0:	0080006f          	j	80200dc8 <strtol+0x258>
    80200dc4:	fe843783          	ld	a5,-24(s0)
}
    80200dc8:	00078513          	mv	a0,a5
    80200dcc:	04813083          	ld	ra,72(sp)
    80200dd0:	04013403          	ld	s0,64(sp)
    80200dd4:	05010113          	addi	sp,sp,80
    80200dd8:	00008067          	ret

0000000080200ddc <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
    80200ddc:	fd010113          	addi	sp,sp,-48
    80200de0:	02113423          	sd	ra,40(sp)
    80200de4:	02813023          	sd	s0,32(sp)
    80200de8:	03010413          	addi	s0,sp,48
    80200dec:	fca43c23          	sd	a0,-40(s0)
    80200df0:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
    80200df4:	fd043783          	ld	a5,-48(s0)
    80200df8:	00079863          	bnez	a5,80200e08 <puts_wo_nl+0x2c>
        s = "(null)";
    80200dfc:	00001797          	auipc	a5,0x1
    80200e00:	2dc78793          	addi	a5,a5,732 # 802020d8 <_srodata+0xd8>
    80200e04:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
    80200e08:	fd043783          	ld	a5,-48(s0)
    80200e0c:	fef43423          	sd	a5,-24(s0)
    while (*p) {
    80200e10:	0240006f          	j	80200e34 <puts_wo_nl+0x58>
        putch(*p++);
    80200e14:	fe843783          	ld	a5,-24(s0)
    80200e18:	00178713          	addi	a4,a5,1
    80200e1c:	fee43423          	sd	a4,-24(s0)
    80200e20:	0007c783          	lbu	a5,0(a5)
    80200e24:	0007871b          	sext.w	a4,a5
    80200e28:	fd843783          	ld	a5,-40(s0)
    80200e2c:	00070513          	mv	a0,a4
    80200e30:	000780e7          	jalr	a5
    while (*p) {
    80200e34:	fe843783          	ld	a5,-24(s0)
    80200e38:	0007c783          	lbu	a5,0(a5)
    80200e3c:	fc079ce3          	bnez	a5,80200e14 <puts_wo_nl+0x38>
    }
    return p - s;
    80200e40:	fe843703          	ld	a4,-24(s0)
    80200e44:	fd043783          	ld	a5,-48(s0)
    80200e48:	40f707b3          	sub	a5,a4,a5
    80200e4c:	0007879b          	sext.w	a5,a5
}
    80200e50:	00078513          	mv	a0,a5
    80200e54:	02813083          	ld	ra,40(sp)
    80200e58:	02013403          	ld	s0,32(sp)
    80200e5c:	03010113          	addi	sp,sp,48
    80200e60:	00008067          	ret

0000000080200e64 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
    80200e64:	f9010113          	addi	sp,sp,-112
    80200e68:	06113423          	sd	ra,104(sp)
    80200e6c:	06813023          	sd	s0,96(sp)
    80200e70:	07010413          	addi	s0,sp,112
    80200e74:	faa43423          	sd	a0,-88(s0)
    80200e78:	fab43023          	sd	a1,-96(s0)
    80200e7c:	00060793          	mv	a5,a2
    80200e80:	f8d43823          	sd	a3,-112(s0)
    80200e84:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
    80200e88:	f9f44783          	lbu	a5,-97(s0)
    80200e8c:	0ff7f793          	zext.b	a5,a5
    80200e90:	02078663          	beqz	a5,80200ebc <print_dec_int+0x58>
    80200e94:	fa043703          	ld	a4,-96(s0)
    80200e98:	fff00793          	li	a5,-1
    80200e9c:	03f79793          	slli	a5,a5,0x3f
    80200ea0:	00f71e63          	bne	a4,a5,80200ebc <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
    80200ea4:	00001597          	auipc	a1,0x1
    80200ea8:	23c58593          	addi	a1,a1,572 # 802020e0 <_srodata+0xe0>
    80200eac:	fa843503          	ld	a0,-88(s0)
    80200eb0:	f2dff0ef          	jal	80200ddc <puts_wo_nl>
    80200eb4:	00050793          	mv	a5,a0
    80200eb8:	2a00006f          	j	80201158 <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
    80200ebc:	f9043783          	ld	a5,-112(s0)
    80200ec0:	00c7a783          	lw	a5,12(a5)
    80200ec4:	00079a63          	bnez	a5,80200ed8 <print_dec_int+0x74>
    80200ec8:	fa043783          	ld	a5,-96(s0)
    80200ecc:	00079663          	bnez	a5,80200ed8 <print_dec_int+0x74>
        return 0;
    80200ed0:	00000793          	li	a5,0
    80200ed4:	2840006f          	j	80201158 <print_dec_int+0x2f4>
    }

    bool neg = false;
    80200ed8:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
    80200edc:	f9f44783          	lbu	a5,-97(s0)
    80200ee0:	0ff7f793          	zext.b	a5,a5
    80200ee4:	02078063          	beqz	a5,80200f04 <print_dec_int+0xa0>
    80200ee8:	fa043783          	ld	a5,-96(s0)
    80200eec:	0007dc63          	bgez	a5,80200f04 <print_dec_int+0xa0>
        neg = true;
    80200ef0:	00100793          	li	a5,1
    80200ef4:	fef407a3          	sb	a5,-17(s0)
        num = -num;
    80200ef8:	fa043783          	ld	a5,-96(s0)
    80200efc:	40f007b3          	neg	a5,a5
    80200f00:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
    80200f04:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
    80200f08:	f9f44783          	lbu	a5,-97(s0)
    80200f0c:	0ff7f793          	zext.b	a5,a5
    80200f10:	02078863          	beqz	a5,80200f40 <print_dec_int+0xdc>
    80200f14:	fef44783          	lbu	a5,-17(s0)
    80200f18:	0ff7f793          	zext.b	a5,a5
    80200f1c:	00079e63          	bnez	a5,80200f38 <print_dec_int+0xd4>
    80200f20:	f9043783          	ld	a5,-112(s0)
    80200f24:	0057c783          	lbu	a5,5(a5)
    80200f28:	00079863          	bnez	a5,80200f38 <print_dec_int+0xd4>
    80200f2c:	f9043783          	ld	a5,-112(s0)
    80200f30:	0047c783          	lbu	a5,4(a5)
    80200f34:	00078663          	beqz	a5,80200f40 <print_dec_int+0xdc>
    80200f38:	00100793          	li	a5,1
    80200f3c:	0080006f          	j	80200f44 <print_dec_int+0xe0>
    80200f40:	00000793          	li	a5,0
    80200f44:	fcf40ba3          	sb	a5,-41(s0)
    80200f48:	fd744783          	lbu	a5,-41(s0)
    80200f4c:	0017f793          	andi	a5,a5,1
    80200f50:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
    80200f54:	fa043703          	ld	a4,-96(s0)
    80200f58:	00a00793          	li	a5,10
    80200f5c:	02f777b3          	remu	a5,a4,a5
    80200f60:	0ff7f713          	zext.b	a4,a5
    80200f64:	fe842783          	lw	a5,-24(s0)
    80200f68:	0017869b          	addiw	a3,a5,1
    80200f6c:	fed42423          	sw	a3,-24(s0)
    80200f70:	0307071b          	addiw	a4,a4,48
    80200f74:	0ff77713          	zext.b	a4,a4
    80200f78:	ff078793          	addi	a5,a5,-16
    80200f7c:	008787b3          	add	a5,a5,s0
    80200f80:	fce78423          	sb	a4,-56(a5)
        num /= 10;
    80200f84:	fa043703          	ld	a4,-96(s0)
    80200f88:	00a00793          	li	a5,10
    80200f8c:	02f757b3          	divu	a5,a4,a5
    80200f90:	faf43023          	sd	a5,-96(s0)
    } while (num);
    80200f94:	fa043783          	ld	a5,-96(s0)
    80200f98:	fa079ee3          	bnez	a5,80200f54 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
    80200f9c:	f9043783          	ld	a5,-112(s0)
    80200fa0:	00c7a783          	lw	a5,12(a5)
    80200fa4:	00078713          	mv	a4,a5
    80200fa8:	fff00793          	li	a5,-1
    80200fac:	02f71063          	bne	a4,a5,80200fcc <print_dec_int+0x168>
    80200fb0:	f9043783          	ld	a5,-112(s0)
    80200fb4:	0037c783          	lbu	a5,3(a5)
    80200fb8:	00078a63          	beqz	a5,80200fcc <print_dec_int+0x168>
        flags->prec = flags->width;
    80200fbc:	f9043783          	ld	a5,-112(s0)
    80200fc0:	0087a703          	lw	a4,8(a5)
    80200fc4:	f9043783          	ld	a5,-112(s0)
    80200fc8:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
    80200fcc:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80200fd0:	f9043783          	ld	a5,-112(s0)
    80200fd4:	0087a703          	lw	a4,8(a5)
    80200fd8:	fe842783          	lw	a5,-24(s0)
    80200fdc:	fcf42823          	sw	a5,-48(s0)
    80200fe0:	f9043783          	ld	a5,-112(s0)
    80200fe4:	00c7a783          	lw	a5,12(a5)
    80200fe8:	fcf42623          	sw	a5,-52(s0)
    80200fec:	fd042783          	lw	a5,-48(s0)
    80200ff0:	00078593          	mv	a1,a5
    80200ff4:	fcc42783          	lw	a5,-52(s0)
    80200ff8:	00078613          	mv	a2,a5
    80200ffc:	0006069b          	sext.w	a3,a2
    80201000:	0005879b          	sext.w	a5,a1
    80201004:	00f6d463          	bge	a3,a5,8020100c <print_dec_int+0x1a8>
    80201008:	00058613          	mv	a2,a1
    8020100c:	0006079b          	sext.w	a5,a2
    80201010:	40f707bb          	subw	a5,a4,a5
    80201014:	0007871b          	sext.w	a4,a5
    80201018:	fd744783          	lbu	a5,-41(s0)
    8020101c:	0007879b          	sext.w	a5,a5
    80201020:	40f707bb          	subw	a5,a4,a5
    80201024:	fef42023          	sw	a5,-32(s0)
    80201028:	0280006f          	j	80201050 <print_dec_int+0x1ec>
        putch(' ');
    8020102c:	fa843783          	ld	a5,-88(s0)
    80201030:	02000513          	li	a0,32
    80201034:	000780e7          	jalr	a5
        ++written;
    80201038:	fe442783          	lw	a5,-28(s0)
    8020103c:	0017879b          	addiw	a5,a5,1
    80201040:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80201044:	fe042783          	lw	a5,-32(s0)
    80201048:	fff7879b          	addiw	a5,a5,-1
    8020104c:	fef42023          	sw	a5,-32(s0)
    80201050:	fe042783          	lw	a5,-32(s0)
    80201054:	0007879b          	sext.w	a5,a5
    80201058:	fcf04ae3          	bgtz	a5,8020102c <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
    8020105c:	fd744783          	lbu	a5,-41(s0)
    80201060:	0ff7f793          	zext.b	a5,a5
    80201064:	04078463          	beqz	a5,802010ac <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
    80201068:	fef44783          	lbu	a5,-17(s0)
    8020106c:	0ff7f793          	zext.b	a5,a5
    80201070:	00078663          	beqz	a5,8020107c <print_dec_int+0x218>
    80201074:	02d00793          	li	a5,45
    80201078:	01c0006f          	j	80201094 <print_dec_int+0x230>
    8020107c:	f9043783          	ld	a5,-112(s0)
    80201080:	0057c783          	lbu	a5,5(a5)
    80201084:	00078663          	beqz	a5,80201090 <print_dec_int+0x22c>
    80201088:	02b00793          	li	a5,43
    8020108c:	0080006f          	j	80201094 <print_dec_int+0x230>
    80201090:	02000793          	li	a5,32
    80201094:	fa843703          	ld	a4,-88(s0)
    80201098:	00078513          	mv	a0,a5
    8020109c:	000700e7          	jalr	a4
        ++written;
    802010a0:	fe442783          	lw	a5,-28(s0)
    802010a4:	0017879b          	addiw	a5,a5,1
    802010a8:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    802010ac:	fe842783          	lw	a5,-24(s0)
    802010b0:	fcf42e23          	sw	a5,-36(s0)
    802010b4:	0280006f          	j	802010dc <print_dec_int+0x278>
        putch('0');
    802010b8:	fa843783          	ld	a5,-88(s0)
    802010bc:	03000513          	li	a0,48
    802010c0:	000780e7          	jalr	a5
        ++written;
    802010c4:	fe442783          	lw	a5,-28(s0)
    802010c8:	0017879b          	addiw	a5,a5,1
    802010cc:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    802010d0:	fdc42783          	lw	a5,-36(s0)
    802010d4:	0017879b          	addiw	a5,a5,1
    802010d8:	fcf42e23          	sw	a5,-36(s0)
    802010dc:	f9043783          	ld	a5,-112(s0)
    802010e0:	00c7a703          	lw	a4,12(a5)
    802010e4:	fd744783          	lbu	a5,-41(s0)
    802010e8:	0007879b          	sext.w	a5,a5
    802010ec:	40f707bb          	subw	a5,a4,a5
    802010f0:	0007871b          	sext.w	a4,a5
    802010f4:	fdc42783          	lw	a5,-36(s0)
    802010f8:	0007879b          	sext.w	a5,a5
    802010fc:	fae7cee3          	blt	a5,a4,802010b8 <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
    80201100:	fe842783          	lw	a5,-24(s0)
    80201104:	fff7879b          	addiw	a5,a5,-1
    80201108:	fcf42c23          	sw	a5,-40(s0)
    8020110c:	03c0006f          	j	80201148 <print_dec_int+0x2e4>
        putch(buf[i]);
    80201110:	fd842783          	lw	a5,-40(s0)
    80201114:	ff078793          	addi	a5,a5,-16
    80201118:	008787b3          	add	a5,a5,s0
    8020111c:	fc87c783          	lbu	a5,-56(a5)
    80201120:	0007871b          	sext.w	a4,a5
    80201124:	fa843783          	ld	a5,-88(s0)
    80201128:	00070513          	mv	a0,a4
    8020112c:	000780e7          	jalr	a5
        ++written;
    80201130:	fe442783          	lw	a5,-28(s0)
    80201134:	0017879b          	addiw	a5,a5,1
    80201138:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
    8020113c:	fd842783          	lw	a5,-40(s0)
    80201140:	fff7879b          	addiw	a5,a5,-1
    80201144:	fcf42c23          	sw	a5,-40(s0)
    80201148:	fd842783          	lw	a5,-40(s0)
    8020114c:	0007879b          	sext.w	a5,a5
    80201150:	fc07d0e3          	bgez	a5,80201110 <print_dec_int+0x2ac>
    }

    return written;
    80201154:	fe442783          	lw	a5,-28(s0)
}
    80201158:	00078513          	mv	a0,a5
    8020115c:	06813083          	ld	ra,104(sp)
    80201160:	06013403          	ld	s0,96(sp)
    80201164:	07010113          	addi	sp,sp,112
    80201168:	00008067          	ret

000000008020116c <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
    8020116c:	f4010113          	addi	sp,sp,-192
    80201170:	0a113c23          	sd	ra,184(sp)
    80201174:	0a813823          	sd	s0,176(sp)
    80201178:	0c010413          	addi	s0,sp,192
    8020117c:	f4a43c23          	sd	a0,-168(s0)
    80201180:	f4b43823          	sd	a1,-176(s0)
    80201184:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
    80201188:	f8043023          	sd	zero,-128(s0)
    8020118c:	f8043423          	sd	zero,-120(s0)

    int written = 0;
    80201190:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
    80201194:	7a40006f          	j	80201938 <vprintfmt+0x7cc>
        if (flags.in_format) {
    80201198:	f8044783          	lbu	a5,-128(s0)
    8020119c:	72078e63          	beqz	a5,802018d8 <vprintfmt+0x76c>
            if (*fmt == '#') {
    802011a0:	f5043783          	ld	a5,-176(s0)
    802011a4:	0007c783          	lbu	a5,0(a5)
    802011a8:	00078713          	mv	a4,a5
    802011ac:	02300793          	li	a5,35
    802011b0:	00f71863          	bne	a4,a5,802011c0 <vprintfmt+0x54>
                flags.sharpflag = true;
    802011b4:	00100793          	li	a5,1
    802011b8:	f8f40123          	sb	a5,-126(s0)
    802011bc:	7700006f          	j	8020192c <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
    802011c0:	f5043783          	ld	a5,-176(s0)
    802011c4:	0007c783          	lbu	a5,0(a5)
    802011c8:	00078713          	mv	a4,a5
    802011cc:	03000793          	li	a5,48
    802011d0:	00f71863          	bne	a4,a5,802011e0 <vprintfmt+0x74>
                flags.zeroflag = true;
    802011d4:	00100793          	li	a5,1
    802011d8:	f8f401a3          	sb	a5,-125(s0)
    802011dc:	7500006f          	j	8020192c <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
    802011e0:	f5043783          	ld	a5,-176(s0)
    802011e4:	0007c783          	lbu	a5,0(a5)
    802011e8:	00078713          	mv	a4,a5
    802011ec:	06c00793          	li	a5,108
    802011f0:	04f70063          	beq	a4,a5,80201230 <vprintfmt+0xc4>
    802011f4:	f5043783          	ld	a5,-176(s0)
    802011f8:	0007c783          	lbu	a5,0(a5)
    802011fc:	00078713          	mv	a4,a5
    80201200:	07a00793          	li	a5,122
    80201204:	02f70663          	beq	a4,a5,80201230 <vprintfmt+0xc4>
    80201208:	f5043783          	ld	a5,-176(s0)
    8020120c:	0007c783          	lbu	a5,0(a5)
    80201210:	00078713          	mv	a4,a5
    80201214:	07400793          	li	a5,116
    80201218:	00f70c63          	beq	a4,a5,80201230 <vprintfmt+0xc4>
    8020121c:	f5043783          	ld	a5,-176(s0)
    80201220:	0007c783          	lbu	a5,0(a5)
    80201224:	00078713          	mv	a4,a5
    80201228:	06a00793          	li	a5,106
    8020122c:	00f71863          	bne	a4,a5,8020123c <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
    80201230:	00100793          	li	a5,1
    80201234:	f8f400a3          	sb	a5,-127(s0)
    80201238:	6f40006f          	j	8020192c <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
    8020123c:	f5043783          	ld	a5,-176(s0)
    80201240:	0007c783          	lbu	a5,0(a5)
    80201244:	00078713          	mv	a4,a5
    80201248:	02b00793          	li	a5,43
    8020124c:	00f71863          	bne	a4,a5,8020125c <vprintfmt+0xf0>
                flags.sign = true;
    80201250:	00100793          	li	a5,1
    80201254:	f8f402a3          	sb	a5,-123(s0)
    80201258:	6d40006f          	j	8020192c <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
    8020125c:	f5043783          	ld	a5,-176(s0)
    80201260:	0007c783          	lbu	a5,0(a5)
    80201264:	00078713          	mv	a4,a5
    80201268:	02000793          	li	a5,32
    8020126c:	00f71863          	bne	a4,a5,8020127c <vprintfmt+0x110>
                flags.spaceflag = true;
    80201270:	00100793          	li	a5,1
    80201274:	f8f40223          	sb	a5,-124(s0)
    80201278:	6b40006f          	j	8020192c <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
    8020127c:	f5043783          	ld	a5,-176(s0)
    80201280:	0007c783          	lbu	a5,0(a5)
    80201284:	00078713          	mv	a4,a5
    80201288:	02a00793          	li	a5,42
    8020128c:	00f71e63          	bne	a4,a5,802012a8 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
    80201290:	f4843783          	ld	a5,-184(s0)
    80201294:	00878713          	addi	a4,a5,8
    80201298:	f4e43423          	sd	a4,-184(s0)
    8020129c:	0007a783          	lw	a5,0(a5)
    802012a0:	f8f42423          	sw	a5,-120(s0)
    802012a4:	6880006f          	j	8020192c <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
    802012a8:	f5043783          	ld	a5,-176(s0)
    802012ac:	0007c783          	lbu	a5,0(a5)
    802012b0:	00078713          	mv	a4,a5
    802012b4:	03000793          	li	a5,48
    802012b8:	04e7f663          	bgeu	a5,a4,80201304 <vprintfmt+0x198>
    802012bc:	f5043783          	ld	a5,-176(s0)
    802012c0:	0007c783          	lbu	a5,0(a5)
    802012c4:	00078713          	mv	a4,a5
    802012c8:	03900793          	li	a5,57
    802012cc:	02e7ec63          	bltu	a5,a4,80201304 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
    802012d0:	f5043783          	ld	a5,-176(s0)
    802012d4:	f5040713          	addi	a4,s0,-176
    802012d8:	00a00613          	li	a2,10
    802012dc:	00070593          	mv	a1,a4
    802012e0:	00078513          	mv	a0,a5
    802012e4:	88dff0ef          	jal	80200b70 <strtol>
    802012e8:	00050793          	mv	a5,a0
    802012ec:	0007879b          	sext.w	a5,a5
    802012f0:	f8f42423          	sw	a5,-120(s0)
                fmt--;
    802012f4:	f5043783          	ld	a5,-176(s0)
    802012f8:	fff78793          	addi	a5,a5,-1
    802012fc:	f4f43823          	sd	a5,-176(s0)
    80201300:	62c0006f          	j	8020192c <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
    80201304:	f5043783          	ld	a5,-176(s0)
    80201308:	0007c783          	lbu	a5,0(a5)
    8020130c:	00078713          	mv	a4,a5
    80201310:	02e00793          	li	a5,46
    80201314:	06f71863          	bne	a4,a5,80201384 <vprintfmt+0x218>
                fmt++;
    80201318:	f5043783          	ld	a5,-176(s0)
    8020131c:	00178793          	addi	a5,a5,1
    80201320:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
    80201324:	f5043783          	ld	a5,-176(s0)
    80201328:	0007c783          	lbu	a5,0(a5)
    8020132c:	00078713          	mv	a4,a5
    80201330:	02a00793          	li	a5,42
    80201334:	00f71e63          	bne	a4,a5,80201350 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
    80201338:	f4843783          	ld	a5,-184(s0)
    8020133c:	00878713          	addi	a4,a5,8
    80201340:	f4e43423          	sd	a4,-184(s0)
    80201344:	0007a783          	lw	a5,0(a5)
    80201348:	f8f42623          	sw	a5,-116(s0)
    8020134c:	5e00006f          	j	8020192c <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
    80201350:	f5043783          	ld	a5,-176(s0)
    80201354:	f5040713          	addi	a4,s0,-176
    80201358:	00a00613          	li	a2,10
    8020135c:	00070593          	mv	a1,a4
    80201360:	00078513          	mv	a0,a5
    80201364:	80dff0ef          	jal	80200b70 <strtol>
    80201368:	00050793          	mv	a5,a0
    8020136c:	0007879b          	sext.w	a5,a5
    80201370:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
    80201374:	f5043783          	ld	a5,-176(s0)
    80201378:	fff78793          	addi	a5,a5,-1
    8020137c:	f4f43823          	sd	a5,-176(s0)
    80201380:	5ac0006f          	j	8020192c <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    80201384:	f5043783          	ld	a5,-176(s0)
    80201388:	0007c783          	lbu	a5,0(a5)
    8020138c:	00078713          	mv	a4,a5
    80201390:	07800793          	li	a5,120
    80201394:	02f70663          	beq	a4,a5,802013c0 <vprintfmt+0x254>
    80201398:	f5043783          	ld	a5,-176(s0)
    8020139c:	0007c783          	lbu	a5,0(a5)
    802013a0:	00078713          	mv	a4,a5
    802013a4:	05800793          	li	a5,88
    802013a8:	00f70c63          	beq	a4,a5,802013c0 <vprintfmt+0x254>
    802013ac:	f5043783          	ld	a5,-176(s0)
    802013b0:	0007c783          	lbu	a5,0(a5)
    802013b4:	00078713          	mv	a4,a5
    802013b8:	07000793          	li	a5,112
    802013bc:	30f71263          	bne	a4,a5,802016c0 <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
    802013c0:	f5043783          	ld	a5,-176(s0)
    802013c4:	0007c783          	lbu	a5,0(a5)
    802013c8:	00078713          	mv	a4,a5
    802013cc:	07000793          	li	a5,112
    802013d0:	00f70663          	beq	a4,a5,802013dc <vprintfmt+0x270>
    802013d4:	f8144783          	lbu	a5,-127(s0)
    802013d8:	00078663          	beqz	a5,802013e4 <vprintfmt+0x278>
    802013dc:	00100793          	li	a5,1
    802013e0:	0080006f          	j	802013e8 <vprintfmt+0x27c>
    802013e4:	00000793          	li	a5,0
    802013e8:	faf403a3          	sb	a5,-89(s0)
    802013ec:	fa744783          	lbu	a5,-89(s0)
    802013f0:	0017f793          	andi	a5,a5,1
    802013f4:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
    802013f8:	fa744783          	lbu	a5,-89(s0)
    802013fc:	0ff7f793          	zext.b	a5,a5
    80201400:	00078c63          	beqz	a5,80201418 <vprintfmt+0x2ac>
    80201404:	f4843783          	ld	a5,-184(s0)
    80201408:	00878713          	addi	a4,a5,8
    8020140c:	f4e43423          	sd	a4,-184(s0)
    80201410:	0007b783          	ld	a5,0(a5)
    80201414:	01c0006f          	j	80201430 <vprintfmt+0x2c4>
    80201418:	f4843783          	ld	a5,-184(s0)
    8020141c:	00878713          	addi	a4,a5,8
    80201420:	f4e43423          	sd	a4,-184(s0)
    80201424:	0007a783          	lw	a5,0(a5)
    80201428:	02079793          	slli	a5,a5,0x20
    8020142c:	0207d793          	srli	a5,a5,0x20
    80201430:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
    80201434:	f8c42783          	lw	a5,-116(s0)
    80201438:	02079463          	bnez	a5,80201460 <vprintfmt+0x2f4>
    8020143c:	fe043783          	ld	a5,-32(s0)
    80201440:	02079063          	bnez	a5,80201460 <vprintfmt+0x2f4>
    80201444:	f5043783          	ld	a5,-176(s0)
    80201448:	0007c783          	lbu	a5,0(a5)
    8020144c:	00078713          	mv	a4,a5
    80201450:	07000793          	li	a5,112
    80201454:	00f70663          	beq	a4,a5,80201460 <vprintfmt+0x2f4>
                    flags.in_format = false;
    80201458:	f8040023          	sb	zero,-128(s0)
    8020145c:	4d00006f          	j	8020192c <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
    80201460:	f5043783          	ld	a5,-176(s0)
    80201464:	0007c783          	lbu	a5,0(a5)
    80201468:	00078713          	mv	a4,a5
    8020146c:	07000793          	li	a5,112
    80201470:	00f70a63          	beq	a4,a5,80201484 <vprintfmt+0x318>
    80201474:	f8244783          	lbu	a5,-126(s0)
    80201478:	00078a63          	beqz	a5,8020148c <vprintfmt+0x320>
    8020147c:	fe043783          	ld	a5,-32(s0)
    80201480:	00078663          	beqz	a5,8020148c <vprintfmt+0x320>
    80201484:	00100793          	li	a5,1
    80201488:	0080006f          	j	80201490 <vprintfmt+0x324>
    8020148c:	00000793          	li	a5,0
    80201490:	faf40323          	sb	a5,-90(s0)
    80201494:	fa644783          	lbu	a5,-90(s0)
    80201498:	0017f793          	andi	a5,a5,1
    8020149c:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
    802014a0:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
    802014a4:	f5043783          	ld	a5,-176(s0)
    802014a8:	0007c783          	lbu	a5,0(a5)
    802014ac:	00078713          	mv	a4,a5
    802014b0:	05800793          	li	a5,88
    802014b4:	00f71863          	bne	a4,a5,802014c4 <vprintfmt+0x358>
    802014b8:	00001797          	auipc	a5,0x1
    802014bc:	c4078793          	addi	a5,a5,-960 # 802020f8 <upperxdigits.1>
    802014c0:	00c0006f          	j	802014cc <vprintfmt+0x360>
    802014c4:	00001797          	auipc	a5,0x1
    802014c8:	c4c78793          	addi	a5,a5,-948 # 80202110 <lowerxdigits.0>
    802014cc:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
    802014d0:	fe043783          	ld	a5,-32(s0)
    802014d4:	00f7f793          	andi	a5,a5,15
    802014d8:	f9843703          	ld	a4,-104(s0)
    802014dc:	00f70733          	add	a4,a4,a5
    802014e0:	fdc42783          	lw	a5,-36(s0)
    802014e4:	0017869b          	addiw	a3,a5,1
    802014e8:	fcd42e23          	sw	a3,-36(s0)
    802014ec:	00074703          	lbu	a4,0(a4)
    802014f0:	ff078793          	addi	a5,a5,-16
    802014f4:	008787b3          	add	a5,a5,s0
    802014f8:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
    802014fc:	fe043783          	ld	a5,-32(s0)
    80201500:	0047d793          	srli	a5,a5,0x4
    80201504:	fef43023          	sd	a5,-32(s0)
                } while (num);
    80201508:	fe043783          	ld	a5,-32(s0)
    8020150c:	fc0792e3          	bnez	a5,802014d0 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
    80201510:	f8c42783          	lw	a5,-116(s0)
    80201514:	00078713          	mv	a4,a5
    80201518:	fff00793          	li	a5,-1
    8020151c:	02f71663          	bne	a4,a5,80201548 <vprintfmt+0x3dc>
    80201520:	f8344783          	lbu	a5,-125(s0)
    80201524:	02078263          	beqz	a5,80201548 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
    80201528:	f8842703          	lw	a4,-120(s0)
    8020152c:	fa644783          	lbu	a5,-90(s0)
    80201530:	0007879b          	sext.w	a5,a5
    80201534:	0017979b          	slliw	a5,a5,0x1
    80201538:	0007879b          	sext.w	a5,a5
    8020153c:	40f707bb          	subw	a5,a4,a5
    80201540:	0007879b          	sext.w	a5,a5
    80201544:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    80201548:	f8842703          	lw	a4,-120(s0)
    8020154c:	fa644783          	lbu	a5,-90(s0)
    80201550:	0007879b          	sext.w	a5,a5
    80201554:	0017979b          	slliw	a5,a5,0x1
    80201558:	0007879b          	sext.w	a5,a5
    8020155c:	40f707bb          	subw	a5,a4,a5
    80201560:	0007871b          	sext.w	a4,a5
    80201564:	fdc42783          	lw	a5,-36(s0)
    80201568:	f8f42a23          	sw	a5,-108(s0)
    8020156c:	f8c42783          	lw	a5,-116(s0)
    80201570:	f8f42823          	sw	a5,-112(s0)
    80201574:	f9442783          	lw	a5,-108(s0)
    80201578:	00078593          	mv	a1,a5
    8020157c:	f9042783          	lw	a5,-112(s0)
    80201580:	00078613          	mv	a2,a5
    80201584:	0006069b          	sext.w	a3,a2
    80201588:	0005879b          	sext.w	a5,a1
    8020158c:	00f6d463          	bge	a3,a5,80201594 <vprintfmt+0x428>
    80201590:	00058613          	mv	a2,a1
    80201594:	0006079b          	sext.w	a5,a2
    80201598:	40f707bb          	subw	a5,a4,a5
    8020159c:	fcf42c23          	sw	a5,-40(s0)
    802015a0:	0280006f          	j	802015c8 <vprintfmt+0x45c>
                    putch(' ');
    802015a4:	f5843783          	ld	a5,-168(s0)
    802015a8:	02000513          	li	a0,32
    802015ac:	000780e7          	jalr	a5
                    ++written;
    802015b0:	fec42783          	lw	a5,-20(s0)
    802015b4:	0017879b          	addiw	a5,a5,1
    802015b8:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    802015bc:	fd842783          	lw	a5,-40(s0)
    802015c0:	fff7879b          	addiw	a5,a5,-1
    802015c4:	fcf42c23          	sw	a5,-40(s0)
    802015c8:	fd842783          	lw	a5,-40(s0)
    802015cc:	0007879b          	sext.w	a5,a5
    802015d0:	fcf04ae3          	bgtz	a5,802015a4 <vprintfmt+0x438>
                }

                if (prefix) {
    802015d4:	fa644783          	lbu	a5,-90(s0)
    802015d8:	0ff7f793          	zext.b	a5,a5
    802015dc:	04078463          	beqz	a5,80201624 <vprintfmt+0x4b8>
                    putch('0');
    802015e0:	f5843783          	ld	a5,-168(s0)
    802015e4:	03000513          	li	a0,48
    802015e8:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
    802015ec:	f5043783          	ld	a5,-176(s0)
    802015f0:	0007c783          	lbu	a5,0(a5)
    802015f4:	00078713          	mv	a4,a5
    802015f8:	05800793          	li	a5,88
    802015fc:	00f71663          	bne	a4,a5,80201608 <vprintfmt+0x49c>
    80201600:	05800793          	li	a5,88
    80201604:	0080006f          	j	8020160c <vprintfmt+0x4a0>
    80201608:	07800793          	li	a5,120
    8020160c:	f5843703          	ld	a4,-168(s0)
    80201610:	00078513          	mv	a0,a5
    80201614:	000700e7          	jalr	a4
                    written += 2;
    80201618:	fec42783          	lw	a5,-20(s0)
    8020161c:	0027879b          	addiw	a5,a5,2
    80201620:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
    80201624:	fdc42783          	lw	a5,-36(s0)
    80201628:	fcf42a23          	sw	a5,-44(s0)
    8020162c:	0280006f          	j	80201654 <vprintfmt+0x4e8>
                    putch('0');
    80201630:	f5843783          	ld	a5,-168(s0)
    80201634:	03000513          	li	a0,48
    80201638:	000780e7          	jalr	a5
                    ++written;
    8020163c:	fec42783          	lw	a5,-20(s0)
    80201640:	0017879b          	addiw	a5,a5,1
    80201644:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
    80201648:	fd442783          	lw	a5,-44(s0)
    8020164c:	0017879b          	addiw	a5,a5,1
    80201650:	fcf42a23          	sw	a5,-44(s0)
    80201654:	f8c42703          	lw	a4,-116(s0)
    80201658:	fd442783          	lw	a5,-44(s0)
    8020165c:	0007879b          	sext.w	a5,a5
    80201660:	fce7c8e3          	blt	a5,a4,80201630 <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
    80201664:	fdc42783          	lw	a5,-36(s0)
    80201668:	fff7879b          	addiw	a5,a5,-1
    8020166c:	fcf42823          	sw	a5,-48(s0)
    80201670:	03c0006f          	j	802016ac <vprintfmt+0x540>
                    putch(buf[i]);
    80201674:	fd042783          	lw	a5,-48(s0)
    80201678:	ff078793          	addi	a5,a5,-16
    8020167c:	008787b3          	add	a5,a5,s0
    80201680:	f807c783          	lbu	a5,-128(a5)
    80201684:	0007871b          	sext.w	a4,a5
    80201688:	f5843783          	ld	a5,-168(s0)
    8020168c:	00070513          	mv	a0,a4
    80201690:	000780e7          	jalr	a5
                    ++written;
    80201694:	fec42783          	lw	a5,-20(s0)
    80201698:	0017879b          	addiw	a5,a5,1
    8020169c:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
    802016a0:	fd042783          	lw	a5,-48(s0)
    802016a4:	fff7879b          	addiw	a5,a5,-1
    802016a8:	fcf42823          	sw	a5,-48(s0)
    802016ac:	fd042783          	lw	a5,-48(s0)
    802016b0:	0007879b          	sext.w	a5,a5
    802016b4:	fc07d0e3          	bgez	a5,80201674 <vprintfmt+0x508>
                }

                flags.in_format = false;
    802016b8:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    802016bc:	2700006f          	j	8020192c <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    802016c0:	f5043783          	ld	a5,-176(s0)
    802016c4:	0007c783          	lbu	a5,0(a5)
    802016c8:	00078713          	mv	a4,a5
    802016cc:	06400793          	li	a5,100
    802016d0:	02f70663          	beq	a4,a5,802016fc <vprintfmt+0x590>
    802016d4:	f5043783          	ld	a5,-176(s0)
    802016d8:	0007c783          	lbu	a5,0(a5)
    802016dc:	00078713          	mv	a4,a5
    802016e0:	06900793          	li	a5,105
    802016e4:	00f70c63          	beq	a4,a5,802016fc <vprintfmt+0x590>
    802016e8:	f5043783          	ld	a5,-176(s0)
    802016ec:	0007c783          	lbu	a5,0(a5)
    802016f0:	00078713          	mv	a4,a5
    802016f4:	07500793          	li	a5,117
    802016f8:	08f71063          	bne	a4,a5,80201778 <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
    802016fc:	f8144783          	lbu	a5,-127(s0)
    80201700:	00078c63          	beqz	a5,80201718 <vprintfmt+0x5ac>
    80201704:	f4843783          	ld	a5,-184(s0)
    80201708:	00878713          	addi	a4,a5,8
    8020170c:	f4e43423          	sd	a4,-184(s0)
    80201710:	0007b783          	ld	a5,0(a5)
    80201714:	0140006f          	j	80201728 <vprintfmt+0x5bc>
    80201718:	f4843783          	ld	a5,-184(s0)
    8020171c:	00878713          	addi	a4,a5,8
    80201720:	f4e43423          	sd	a4,-184(s0)
    80201724:	0007a783          	lw	a5,0(a5)
    80201728:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
    8020172c:	fa843583          	ld	a1,-88(s0)
    80201730:	f5043783          	ld	a5,-176(s0)
    80201734:	0007c783          	lbu	a5,0(a5)
    80201738:	0007871b          	sext.w	a4,a5
    8020173c:	07500793          	li	a5,117
    80201740:	40f707b3          	sub	a5,a4,a5
    80201744:	00f037b3          	snez	a5,a5
    80201748:	0ff7f793          	zext.b	a5,a5
    8020174c:	f8040713          	addi	a4,s0,-128
    80201750:	00070693          	mv	a3,a4
    80201754:	00078613          	mv	a2,a5
    80201758:	f5843503          	ld	a0,-168(s0)
    8020175c:	f08ff0ef          	jal	80200e64 <print_dec_int>
    80201760:	00050793          	mv	a5,a0
    80201764:	fec42703          	lw	a4,-20(s0)
    80201768:	00f707bb          	addw	a5,a4,a5
    8020176c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201770:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    80201774:	1b80006f          	j	8020192c <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
    80201778:	f5043783          	ld	a5,-176(s0)
    8020177c:	0007c783          	lbu	a5,0(a5)
    80201780:	00078713          	mv	a4,a5
    80201784:	06e00793          	li	a5,110
    80201788:	04f71c63          	bne	a4,a5,802017e0 <vprintfmt+0x674>
                if (flags.longflag) {
    8020178c:	f8144783          	lbu	a5,-127(s0)
    80201790:	02078463          	beqz	a5,802017b8 <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
    80201794:	f4843783          	ld	a5,-184(s0)
    80201798:	00878713          	addi	a4,a5,8
    8020179c:	f4e43423          	sd	a4,-184(s0)
    802017a0:	0007b783          	ld	a5,0(a5)
    802017a4:	faf43823          	sd	a5,-80(s0)
                    *n = written;
    802017a8:	fec42703          	lw	a4,-20(s0)
    802017ac:	fb043783          	ld	a5,-80(s0)
    802017b0:	00e7b023          	sd	a4,0(a5)
    802017b4:	0240006f          	j	802017d8 <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
    802017b8:	f4843783          	ld	a5,-184(s0)
    802017bc:	00878713          	addi	a4,a5,8
    802017c0:	f4e43423          	sd	a4,-184(s0)
    802017c4:	0007b783          	ld	a5,0(a5)
    802017c8:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
    802017cc:	fb843783          	ld	a5,-72(s0)
    802017d0:	fec42703          	lw	a4,-20(s0)
    802017d4:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
    802017d8:	f8040023          	sb	zero,-128(s0)
    802017dc:	1500006f          	j	8020192c <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
    802017e0:	f5043783          	ld	a5,-176(s0)
    802017e4:	0007c783          	lbu	a5,0(a5)
    802017e8:	00078713          	mv	a4,a5
    802017ec:	07300793          	li	a5,115
    802017f0:	02f71e63          	bne	a4,a5,8020182c <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
    802017f4:	f4843783          	ld	a5,-184(s0)
    802017f8:	00878713          	addi	a4,a5,8
    802017fc:	f4e43423          	sd	a4,-184(s0)
    80201800:	0007b783          	ld	a5,0(a5)
    80201804:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
    80201808:	fc043583          	ld	a1,-64(s0)
    8020180c:	f5843503          	ld	a0,-168(s0)
    80201810:	dccff0ef          	jal	80200ddc <puts_wo_nl>
    80201814:	00050793          	mv	a5,a0
    80201818:	fec42703          	lw	a4,-20(s0)
    8020181c:	00f707bb          	addw	a5,a4,a5
    80201820:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201824:	f8040023          	sb	zero,-128(s0)
    80201828:	1040006f          	j	8020192c <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
    8020182c:	f5043783          	ld	a5,-176(s0)
    80201830:	0007c783          	lbu	a5,0(a5)
    80201834:	00078713          	mv	a4,a5
    80201838:	06300793          	li	a5,99
    8020183c:	02f71e63          	bne	a4,a5,80201878 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
    80201840:	f4843783          	ld	a5,-184(s0)
    80201844:	00878713          	addi	a4,a5,8
    80201848:	f4e43423          	sd	a4,-184(s0)
    8020184c:	0007a783          	lw	a5,0(a5)
    80201850:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
    80201854:	fcc42703          	lw	a4,-52(s0)
    80201858:	f5843783          	ld	a5,-168(s0)
    8020185c:	00070513          	mv	a0,a4
    80201860:	000780e7          	jalr	a5
                ++written;
    80201864:	fec42783          	lw	a5,-20(s0)
    80201868:	0017879b          	addiw	a5,a5,1
    8020186c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201870:	f8040023          	sb	zero,-128(s0)
    80201874:	0b80006f          	j	8020192c <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
    80201878:	f5043783          	ld	a5,-176(s0)
    8020187c:	0007c783          	lbu	a5,0(a5)
    80201880:	00078713          	mv	a4,a5
    80201884:	02500793          	li	a5,37
    80201888:	02f71263          	bne	a4,a5,802018ac <vprintfmt+0x740>
                putch('%');
    8020188c:	f5843783          	ld	a5,-168(s0)
    80201890:	02500513          	li	a0,37
    80201894:	000780e7          	jalr	a5
                ++written;
    80201898:	fec42783          	lw	a5,-20(s0)
    8020189c:	0017879b          	addiw	a5,a5,1
    802018a0:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802018a4:	f8040023          	sb	zero,-128(s0)
    802018a8:	0840006f          	j	8020192c <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
    802018ac:	f5043783          	ld	a5,-176(s0)
    802018b0:	0007c783          	lbu	a5,0(a5)
    802018b4:	0007871b          	sext.w	a4,a5
    802018b8:	f5843783          	ld	a5,-168(s0)
    802018bc:	00070513          	mv	a0,a4
    802018c0:	000780e7          	jalr	a5
                ++written;
    802018c4:	fec42783          	lw	a5,-20(s0)
    802018c8:	0017879b          	addiw	a5,a5,1
    802018cc:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802018d0:	f8040023          	sb	zero,-128(s0)
    802018d4:	0580006f          	j	8020192c <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
    802018d8:	f5043783          	ld	a5,-176(s0)
    802018dc:	0007c783          	lbu	a5,0(a5)
    802018e0:	00078713          	mv	a4,a5
    802018e4:	02500793          	li	a5,37
    802018e8:	02f71063          	bne	a4,a5,80201908 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
    802018ec:	f8043023          	sd	zero,-128(s0)
    802018f0:	f8043423          	sd	zero,-120(s0)
    802018f4:	00100793          	li	a5,1
    802018f8:	f8f40023          	sb	a5,-128(s0)
    802018fc:	fff00793          	li	a5,-1
    80201900:	f8f42623          	sw	a5,-116(s0)
    80201904:	0280006f          	j	8020192c <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
    80201908:	f5043783          	ld	a5,-176(s0)
    8020190c:	0007c783          	lbu	a5,0(a5)
    80201910:	0007871b          	sext.w	a4,a5
    80201914:	f5843783          	ld	a5,-168(s0)
    80201918:	00070513          	mv	a0,a4
    8020191c:	000780e7          	jalr	a5
            ++written;
    80201920:	fec42783          	lw	a5,-20(s0)
    80201924:	0017879b          	addiw	a5,a5,1
    80201928:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
    8020192c:	f5043783          	ld	a5,-176(s0)
    80201930:	00178793          	addi	a5,a5,1
    80201934:	f4f43823          	sd	a5,-176(s0)
    80201938:	f5043783          	ld	a5,-176(s0)
    8020193c:	0007c783          	lbu	a5,0(a5)
    80201940:	84079ce3          	bnez	a5,80201198 <vprintfmt+0x2c>
        }
    }

    return written;
    80201944:	fec42783          	lw	a5,-20(s0)
}
    80201948:	00078513          	mv	a0,a5
    8020194c:	0b813083          	ld	ra,184(sp)
    80201950:	0b013403          	ld	s0,176(sp)
    80201954:	0c010113          	addi	sp,sp,192
    80201958:	00008067          	ret

000000008020195c <printk>:

int printk(const char* s, ...) {
    8020195c:	f9010113          	addi	sp,sp,-112
    80201960:	02113423          	sd	ra,40(sp)
    80201964:	02813023          	sd	s0,32(sp)
    80201968:	03010413          	addi	s0,sp,48
    8020196c:	fca43c23          	sd	a0,-40(s0)
    80201970:	00b43423          	sd	a1,8(s0)
    80201974:	00c43823          	sd	a2,16(s0)
    80201978:	00d43c23          	sd	a3,24(s0)
    8020197c:	02e43023          	sd	a4,32(s0)
    80201980:	02f43423          	sd	a5,40(s0)
    80201984:	03043823          	sd	a6,48(s0)
    80201988:	03143c23          	sd	a7,56(s0)
    int res = 0;
    8020198c:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
    80201990:	04040793          	addi	a5,s0,64
    80201994:	fcf43823          	sd	a5,-48(s0)
    80201998:	fd043783          	ld	a5,-48(s0)
    8020199c:	fc878793          	addi	a5,a5,-56
    802019a0:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
    802019a4:	fe043783          	ld	a5,-32(s0)
    802019a8:	00078613          	mv	a2,a5
    802019ac:	fd843583          	ld	a1,-40(s0)
    802019b0:	fffff517          	auipc	a0,0xfffff
    802019b4:	11850513          	addi	a0,a0,280 # 80200ac8 <putc>
    802019b8:	fb4ff0ef          	jal	8020116c <vprintfmt>
    802019bc:	00050793          	mv	a5,a0
    802019c0:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
    802019c4:	fec42783          	lw	a5,-20(s0)
}
    802019c8:	00078513          	mv	a0,a5
    802019cc:	02813083          	ld	ra,40(sp)
    802019d0:	02013403          	ld	s0,32(sp)
    802019d4:	07010113          	addi	sp,sp,112
    802019d8:	00008067          	ret

00000000802019dc <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
    802019dc:	fe010113          	addi	sp,sp,-32
    802019e0:	00813c23          	sd	s0,24(sp)
    802019e4:	02010413          	addi	s0,sp,32
    802019e8:	00050793          	mv	a5,a0
    802019ec:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
    802019f0:	fec42783          	lw	a5,-20(s0)
    802019f4:	fff7879b          	addiw	a5,a5,-1
    802019f8:	0007879b          	sext.w	a5,a5
    802019fc:	02079713          	slli	a4,a5,0x20
    80201a00:	02075713          	srli	a4,a4,0x20
    80201a04:	00003797          	auipc	a5,0x3
    80201a08:	63c78793          	addi	a5,a5,1596 # 80205040 <seed>
    80201a0c:	00e7b023          	sd	a4,0(a5)
}
    80201a10:	00000013          	nop
    80201a14:	01813403          	ld	s0,24(sp)
    80201a18:	02010113          	addi	sp,sp,32
    80201a1c:	00008067          	ret

0000000080201a20 <rand>:

int rand(void) {
    80201a20:	ff010113          	addi	sp,sp,-16
    80201a24:	00813423          	sd	s0,8(sp)
    80201a28:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
    80201a2c:	00003797          	auipc	a5,0x3
    80201a30:	61478793          	addi	a5,a5,1556 # 80205040 <seed>
    80201a34:	0007b703          	ld	a4,0(a5)
    80201a38:	00000797          	auipc	a5,0x0
    80201a3c:	6f078793          	addi	a5,a5,1776 # 80202128 <lowerxdigits.0+0x18>
    80201a40:	0007b783          	ld	a5,0(a5)
    80201a44:	02f707b3          	mul	a5,a4,a5
    80201a48:	00178713          	addi	a4,a5,1
    80201a4c:	00003797          	auipc	a5,0x3
    80201a50:	5f478793          	addi	a5,a5,1524 # 80205040 <seed>
    80201a54:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
    80201a58:	00003797          	auipc	a5,0x3
    80201a5c:	5e878793          	addi	a5,a5,1512 # 80205040 <seed>
    80201a60:	0007b783          	ld	a5,0(a5)
    80201a64:	0217d793          	srli	a5,a5,0x21
    80201a68:	0007879b          	sext.w	a5,a5
}
    80201a6c:	00078513          	mv	a0,a5
    80201a70:	00813403          	ld	s0,8(sp)
    80201a74:	01010113          	addi	sp,sp,16
    80201a78:	00008067          	ret

0000000080201a7c <memset>:
#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
    80201a7c:	fc010113          	addi	sp,sp,-64
    80201a80:	02813c23          	sd	s0,56(sp)
    80201a84:	04010413          	addi	s0,sp,64
    80201a88:	fca43c23          	sd	a0,-40(s0)
    80201a8c:	00058793          	mv	a5,a1
    80201a90:	fcc43423          	sd	a2,-56(s0)
    80201a94:	fcf42a23          	sw	a5,-44(s0)
    char *s = (char *)dest;
    80201a98:	fd843783          	ld	a5,-40(s0)
    80201a9c:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
    80201aa0:	fe043423          	sd	zero,-24(s0)
    80201aa4:	0280006f          	j	80201acc <memset+0x50>
        s[i] = c;
    80201aa8:	fe043703          	ld	a4,-32(s0)
    80201aac:	fe843783          	ld	a5,-24(s0)
    80201ab0:	00f707b3          	add	a5,a4,a5
    80201ab4:	fd442703          	lw	a4,-44(s0)
    80201ab8:	0ff77713          	zext.b	a4,a4
    80201abc:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
    80201ac0:	fe843783          	ld	a5,-24(s0)
    80201ac4:	00178793          	addi	a5,a5,1
    80201ac8:	fef43423          	sd	a5,-24(s0)
    80201acc:	fe843703          	ld	a4,-24(s0)
    80201ad0:	fc843783          	ld	a5,-56(s0)
    80201ad4:	fcf76ae3          	bltu	a4,a5,80201aa8 <memset+0x2c>
    }
    return dest;
    80201ad8:	fd843783          	ld	a5,-40(s0)
}
    80201adc:	00078513          	mv	a0,a5
    80201ae0:	03813403          	ld	s0,56(sp)
    80201ae4:	04010113          	addi	sp,sp,64
    80201ae8:	00008067          	ret
