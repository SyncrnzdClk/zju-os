
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
    80200004:	01013103          	ld	sp,16(sp) # 80203010 <_GLOBAL_OFFSET_TABLE_+0x8>

    # set stvec = _traps
    la t0, _traps
    80200008:	00003297          	auipc	t0,0x3
    8020000c:	0102b283          	ld	t0,16(t0) # 80203018 <_GLOBAL_OFFSET_TABLE_+0x10>
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
    80200024:	160000ef          	jal	80200184 <clock_set_next_event>
    
    # set sstatus[SIE] = 1, SIE is the 1st bit
    csrr t0, sstatus
    80200028:	100022f3          	csrr	t0,sstatus
    li t1, 1 << 1
    8020002c:	00200313          	li	t1,2
    or t0, t0, t1
    80200030:	0062e2b3          	or	t0,t0,t1
    csrw sstatus, t0
    80200034:	10029073          	csrw	sstatus,t0

    j start_kernel
    80200038:	51c0006f          	j	80200554 <start_kernel>

000000008020003c <_traps>:
    .globl _traps 
_traps:
    # #error Unimplemented

    # 1. save 32 registers and sepc to stack
    addi sp, sp, -32*8 # x0 is not saved
    8020003c:	f0010113          	addi	sp,sp,-256
    sd ra, 0(sp)            
    80200040:	00113023          	sd	ra,0(sp)
    sd sp, 8(sp)
    80200044:	00213423          	sd	sp,8(sp)
    sd gp, 16(sp)
    80200048:	00313823          	sd	gp,16(sp)
    sd tp, 24(sp)
    8020004c:	00413c23          	sd	tp,24(sp)
    sd t0, 32(sp)
    80200050:	02513023          	sd	t0,32(sp)
    sd t1, 40(sp)
    80200054:	02613423          	sd	t1,40(sp)
    sd t2, 48(sp)
    80200058:	02713823          	sd	t2,48(sp)
    sd s0, 56(sp)
    8020005c:	02813c23          	sd	s0,56(sp)
    sd s1, 64(sp)
    80200060:	04913023          	sd	s1,64(sp)
    sd a0, 72(sp)
    80200064:	04a13423          	sd	a0,72(sp)
    sd a1, 80(sp)
    80200068:	04b13823          	sd	a1,80(sp)
    sd a2, 88(sp)
    8020006c:	04c13c23          	sd	a2,88(sp)
    sd a3, 96(sp)
    80200070:	06d13023          	sd	a3,96(sp)
    sd a4, 104(sp)
    80200074:	06e13423          	sd	a4,104(sp)
    sd a5, 112(sp)
    80200078:	06f13823          	sd	a5,112(sp)
    sd a6, 120(sp)
    8020007c:	07013c23          	sd	a6,120(sp)
    sd a7, 128(sp)
    80200080:	09113023          	sd	a7,128(sp)
    sd s2, 136(sp)
    80200084:	09213423          	sd	s2,136(sp)
    sd s3, 144(sp)
    80200088:	09313823          	sd	s3,144(sp)
    sd s4, 152(sp)
    8020008c:	09413c23          	sd	s4,152(sp)
    sd s5, 160(sp)
    80200090:	0b513023          	sd	s5,160(sp)
    sd s6, 168(sp)
    80200094:	0b613423          	sd	s6,168(sp)
    sd s7, 176(sp)
    80200098:	0b713823          	sd	s7,176(sp)
    sd s8, 184(sp)
    8020009c:	0b813c23          	sd	s8,184(sp)
    sd s9, 192(sp)
    802000a0:	0d913023          	sd	s9,192(sp)
    sd s10, 200(sp)
    802000a4:	0da13423          	sd	s10,200(sp)
    sd s11, 208(sp)
    802000a8:	0db13823          	sd	s11,208(sp)
    sd t3, 216(sp)
    802000ac:	0dc13c23          	sd	t3,216(sp)
    sd t4, 224(sp)
    802000b0:	0fd13023          	sd	t4,224(sp)
    sd t5, 232(sp)
    802000b4:	0fe13423          	sd	t5,232(sp)
    sd t6, 240(sp)
    802000b8:	0ff13823          	sd	t6,240(sp)
   
    # save sepc
    csrr t0, sepc      
    802000bc:	141022f3          	csrr	t0,sepc
    sd t0, 248(sp)     
    802000c0:	0e513c23          	sd	t0,248(sp)

    # 2. call trap_handler

    # pass the arguments
    csrr a0, scause
    802000c4:	14202573          	csrr	a0,scause
    csrr a1, sepc
    802000c8:	141025f3          	csrr	a1,sepc

    # call trap_handler
    call trap_handler
    802000cc:	3b4000ef          	jal	80200480 <trap_handler>
    
    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
    
    # first restore sepc
    ld t0, 248(sp)
    802000d0:	0f813283          	ld	t0,248(sp)
    csrw sepc, t0
    802000d4:	14129073          	csrw	sepc,t0

    # restore 32 registers (sp is the last one to be restored)
    ld t6, 240(sp)
    802000d8:	0f013f83          	ld	t6,240(sp)
    ld t5, 232(sp)
    802000dc:	0e813f03          	ld	t5,232(sp)
    ld t4, 224(sp)
    802000e0:	0e013e83          	ld	t4,224(sp)
    ld t3, 216(sp)
    802000e4:	0d813e03          	ld	t3,216(sp)
    ld s11, 208(sp)
    802000e8:	0d013d83          	ld	s11,208(sp)
    ld s10, 200(sp)
    802000ec:	0c813d03          	ld	s10,200(sp)
    ld s9, 192(sp)
    802000f0:	0c013c83          	ld	s9,192(sp)
    ld s8, 184(sp)
    802000f4:	0b813c03          	ld	s8,184(sp)
    ld s7, 176(sp)
    802000f8:	0b013b83          	ld	s7,176(sp)
    ld s6, 168(sp)
    802000fc:	0a813b03          	ld	s6,168(sp)
    ld s5, 160(sp)
    80200100:	0a013a83          	ld	s5,160(sp)
    ld s4, 152(sp)
    80200104:	09813a03          	ld	s4,152(sp)
    ld s3, 144(sp)
    80200108:	09013983          	ld	s3,144(sp)
    ld s2, 136(sp)
    8020010c:	08813903          	ld	s2,136(sp)
    ld a7, 128(sp)
    80200110:	08013883          	ld	a7,128(sp)
    ld a6, 120(sp)
    80200114:	07813803          	ld	a6,120(sp)
    ld a5, 112(sp)
    80200118:	07013783          	ld	a5,112(sp)
    ld a4, 104(sp)
    8020011c:	06813703          	ld	a4,104(sp)
    ld a3, 96(sp)
    80200120:	06013683          	ld	a3,96(sp)
    ld a2, 88(sp)
    80200124:	05813603          	ld	a2,88(sp)
    ld a1, 80(sp)
    80200128:	05013583          	ld	a1,80(sp)
    ld a0, 72(sp)
    8020012c:	04813503          	ld	a0,72(sp)
    ld s1, 64(sp)
    80200130:	04013483          	ld	s1,64(sp)
    ld s0, 56(sp)
    80200134:	03813403          	ld	s0,56(sp)
    ld t2, 48(sp)
    80200138:	03013383          	ld	t2,48(sp)
    ld t1, 40(sp)
    8020013c:	02813303          	ld	t1,40(sp)
    ld t0, 32(sp)
    80200140:	02013283          	ld	t0,32(sp)
    ld tp, 24(sp)
    80200144:	01813203          	ld	tp,24(sp)
    ld gp, 16(sp)
    80200148:	01013183          	ld	gp,16(sp)
    ld ra, 0(sp)
    8020014c:	00013083          	ld	ra,0(sp)
    ld sp, 8(sp)
    80200150:	00813103          	ld	sp,8(sp)

    # reset sp
    addi sp, sp, 33*8
    80200154:	10810113          	addi	sp,sp,264

    # 4. return from trap
    80200158:	10200073          	sret

000000008020015c <get_cycles>:
#include "sbi.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
    8020015c:	fe010113          	addi	sp,sp,-32
    80200160:	00813c23          	sd	s0,24(sp)
    80200164:	02010413          	addi	s0,sp,32
    uint64_t cycles;
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    __asm__ volatile(
    80200168:	c01027f3          	rdtime	a5
    8020016c:	fef43423          	sd	a5,-24(s0)
        // read the time from mtime
        "rdtime %[cycles]"
        : [cycles] "=r" (cycles)
    );
    return cycles;
    80200170:	fe843783          	ld	a5,-24(s0)
    // #error Unimplemented
}
    80200174:	00078513          	mv	a0,a5
    80200178:	01813403          	ld	s0,24(sp)
    8020017c:	02010113          	addi	sp,sp,32
    80200180:	00008067          	ret

0000000080200184 <clock_set_next_event>:

void clock_set_next_event() {
    80200184:	fe010113          	addi	sp,sp,-32
    80200188:	00113c23          	sd	ra,24(sp)
    8020018c:	00813823          	sd	s0,16(sp)
    80200190:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
    80200194:	fc9ff0ef          	jal	8020015c <get_cycles>
    80200198:	00050713          	mv	a4,a0
    8020019c:	00003797          	auipc	a5,0x3
    802001a0:	e6478793          	addi	a5,a5,-412 # 80203000 <TIMECLOCK>
    802001a4:	0007b783          	ld	a5,0(a5)
    802001a8:	00f707b3          	add	a5,a4,a5
    802001ac:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
    sbi_set_timer(next);
    802001b0:	fe843503          	ld	a0,-24(s0)
    802001b4:	234000ef          	jal	802003e8 <sbi_set_timer>
    // #error Unimplemented
    802001b8:	00000013          	nop
    802001bc:	01813083          	ld	ra,24(sp)
    802001c0:	01013403          	ld	s0,16(sp)
    802001c4:	02010113          	addi	sp,sp,32
    802001c8:	00008067          	ret

00000000802001cc <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    802001cc:	f8010113          	addi	sp,sp,-128
    802001d0:	06813c23          	sd	s0,120(sp)
    802001d4:	06913823          	sd	s1,112(sp)
    802001d8:	07213423          	sd	s2,104(sp)
    802001dc:	07313023          	sd	s3,96(sp)
    802001e0:	08010413          	addi	s0,sp,128
    802001e4:	faa43c23          	sd	a0,-72(s0)
    802001e8:	fab43823          	sd	a1,-80(s0)
    802001ec:	fac43423          	sd	a2,-88(s0)
    802001f0:	fad43023          	sd	a3,-96(s0)
    802001f4:	f8e43c23          	sd	a4,-104(s0)
    802001f8:	f8f43823          	sd	a5,-112(s0)
    802001fc:	f9043423          	sd	a6,-120(s0)
    80200200:	f9143023          	sd	a7,-128(s0)
    // #error Unimplemented
    struct sbiret ret;

    __asm__ volatile (
    80200204:	fb843e03          	ld	t3,-72(s0)
    80200208:	fb043e83          	ld	t4,-80(s0)
    8020020c:	f8043f03          	ld	t5,-128(s0)
    80200210:	f8843f83          	ld	t6,-120(s0)
    80200214:	f9043283          	ld	t0,-112(s0)
    80200218:	f9843483          	ld	s1,-104(s0)
    8020021c:	fa043903          	ld	s2,-96(s0)
    80200220:	fa843983          	ld	s3,-88(s0)
    80200224:	000e0893          	mv	a7,t3
    80200228:	000e8813          	mv	a6,t4
    8020022c:	000f0793          	mv	a5,t5
    80200230:	000f8713          	mv	a4,t6
    80200234:	00028693          	mv	a3,t0
    80200238:	00048613          	mv	a2,s1
    8020023c:	00090593          	mv	a1,s2
    80200240:	00098513          	mv	a0,s3
    80200244:	00000073          	ecall
    80200248:	00050e93          	mv	t4,a0
    8020024c:	00058e13          	mv	t3,a1
    80200250:	fdd43023          	sd	t4,-64(s0)
    80200254:	fdc43423          	sd	t3,-56(s0)
        "mv %[ret_val], a1\n"
        : [error] "=r" (ret.error), [ret_val] "=r" (ret.value)
        : [eid] "r" (eid), [fid] "r" (fid), [arg5] "r" (arg5), [arg4] "r" (arg4), [arg3] "r" (arg3), [arg2] "r" (arg2), [arg1] "r" (arg1), [arg0] "r" (arg0)
        : "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "memory"
    );
    return ret;
    80200258:	fc043783          	ld	a5,-64(s0)
    8020025c:	fcf43823          	sd	a5,-48(s0)
    80200260:	fc843783          	ld	a5,-56(s0)
    80200264:	fcf43c23          	sd	a5,-40(s0)
    80200268:	fd043703          	ld	a4,-48(s0)
    8020026c:	fd843783          	ld	a5,-40(s0)
    80200270:	00070313          	mv	t1,a4
    80200274:	00078393          	mv	t2,a5
    80200278:	00030713          	mv	a4,t1
    8020027c:	00038793          	mv	a5,t2
}
    80200280:	00070513          	mv	a0,a4
    80200284:	00078593          	mv	a1,a5
    80200288:	07813403          	ld	s0,120(sp)
    8020028c:	07013483          	ld	s1,112(sp)
    80200290:	06813903          	ld	s2,104(sp)
    80200294:	06013983          	ld	s3,96(sp)
    80200298:	08010113          	addi	sp,sp,128
    8020029c:	00008067          	ret

00000000802002a0 <sbi_debug_console_write_byte>:

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    802002a0:	fb010113          	addi	sp,sp,-80
    802002a4:	04113423          	sd	ra,72(sp)
    802002a8:	04813023          	sd	s0,64(sp)
    802002ac:	03213c23          	sd	s2,56(sp)
    802002b0:	03313823          	sd	s3,48(sp)
    802002b4:	05010413          	addi	s0,sp,80
    802002b8:	00050793          	mv	a5,a0
    802002bc:	faf40fa3          	sb	a5,-65(s0)
    // #error Unimplemented
    // set eid and fid
    uint64_t sbi_debug_console_write_byte_eid = 0x4442434E;
    802002c0:	444247b7          	lui	a5,0x44424
    802002c4:	34e78793          	addi	a5,a5,846 # 4442434e <_skernel-0x3bddbcb2>
    802002c8:	fcf43c23          	sd	a5,-40(s0)
    uint64_t sbi_debug_console_write_byte_fid = 2;
    802002cc:	00200793          	li	a5,2
    802002d0:	fcf43823          	sd	a5,-48(s0)
    return sbi_ecall(sbi_debug_console_write_byte_eid, sbi_debug_console_write_byte_fid, byte, 0, 0, 0, 0, 0);
    802002d4:	fbf44603          	lbu	a2,-65(s0)
    802002d8:	00000893          	li	a7,0
    802002dc:	00000813          	li	a6,0
    802002e0:	00000793          	li	a5,0
    802002e4:	00000713          	li	a4,0
    802002e8:	00000693          	li	a3,0
    802002ec:	fd043583          	ld	a1,-48(s0)
    802002f0:	fd843503          	ld	a0,-40(s0)
    802002f4:	ed9ff0ef          	jal	802001cc <sbi_ecall>
    802002f8:	00050713          	mv	a4,a0
    802002fc:	00058793          	mv	a5,a1
    80200300:	fce43023          	sd	a4,-64(s0)
    80200304:	fcf43423          	sd	a5,-56(s0)
    80200308:	fc043703          	ld	a4,-64(s0)
    8020030c:	fc843783          	ld	a5,-56(s0)
    80200310:	00070913          	mv	s2,a4
    80200314:	00078993          	mv	s3,a5
    80200318:	00090713          	mv	a4,s2
    8020031c:	00098793          	mv	a5,s3

}
    80200320:	00070513          	mv	a0,a4
    80200324:	00078593          	mv	a1,a5
    80200328:	04813083          	ld	ra,72(sp)
    8020032c:	04013403          	ld	s0,64(sp)
    80200330:	03813903          	ld	s2,56(sp)
    80200334:	03013983          	ld	s3,48(sp)
    80200338:	05010113          	addi	sp,sp,80
    8020033c:	00008067          	ret

0000000080200340 <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    80200340:	fb010113          	addi	sp,sp,-80
    80200344:	04113423          	sd	ra,72(sp)
    80200348:	04813023          	sd	s0,64(sp)
    8020034c:	03213c23          	sd	s2,56(sp)
    80200350:	03313823          	sd	s3,48(sp)
    80200354:	05010413          	addi	s0,sp,80
    80200358:	00050793          	mv	a5,a0
    8020035c:	00058713          	mv	a4,a1
    80200360:	faf42e23          	sw	a5,-68(s0)
    80200364:	00070793          	mv	a5,a4
    80200368:	faf42c23          	sw	a5,-72(s0)
    // #error Unimplemented
    // set eid and fid
    uint64_t sbi_system_reset_eid = 0x53525354;
    8020036c:	535257b7          	lui	a5,0x53525
    80200370:	35478793          	addi	a5,a5,852 # 53525354 <_skernel-0x2ccdacac>
    80200374:	fcf43c23          	sd	a5,-40(s0)
    uint64_t sbi_system_reset_fid = 0;
    80200378:	fc043823          	sd	zero,-48(s0)
    return sbi_ecall(sbi_system_reset_eid, sbi_system_reset_fid, reset_type, reset_reason, 0, 0, 0, 0);
    8020037c:	fbc46603          	lwu	a2,-68(s0)
    80200380:	fb846683          	lwu	a3,-72(s0)
    80200384:	00000893          	li	a7,0
    80200388:	00000813          	li	a6,0
    8020038c:	00000793          	li	a5,0
    80200390:	00000713          	li	a4,0
    80200394:	fd043583          	ld	a1,-48(s0)
    80200398:	fd843503          	ld	a0,-40(s0)
    8020039c:	e31ff0ef          	jal	802001cc <sbi_ecall>
    802003a0:	00050713          	mv	a4,a0
    802003a4:	00058793          	mv	a5,a1
    802003a8:	fce43023          	sd	a4,-64(s0)
    802003ac:	fcf43423          	sd	a5,-56(s0)
    802003b0:	fc043703          	ld	a4,-64(s0)
    802003b4:	fc843783          	ld	a5,-56(s0)
    802003b8:	00070913          	mv	s2,a4
    802003bc:	00078993          	mv	s3,a5
    802003c0:	00090713          	mv	a4,s2
    802003c4:	00098793          	mv	a5,s3
}
    802003c8:	00070513          	mv	a0,a4
    802003cc:	00078593          	mv	a1,a5
    802003d0:	04813083          	ld	ra,72(sp)
    802003d4:	04013403          	ld	s0,64(sp)
    802003d8:	03813903          	ld	s2,56(sp)
    802003dc:	03013983          	ld	s3,48(sp)
    802003e0:	05010113          	addi	sp,sp,80
    802003e4:	00008067          	ret

00000000802003e8 <sbi_set_timer>:


struct sbiret sbi_set_timer(uint64_t stime_value) {
    802003e8:	fb010113          	addi	sp,sp,-80
    802003ec:	04113423          	sd	ra,72(sp)
    802003f0:	04813023          	sd	s0,64(sp)
    802003f4:	03213c23          	sd	s2,56(sp)
    802003f8:	03313823          	sd	s3,48(sp)
    802003fc:	05010413          	addi	s0,sp,80
    80200400:	faa43c23          	sd	a0,-72(s0)
    // set eid and fid
    uint64_t sbi_set_timer_eid = 0x54494D45;
    80200404:	544957b7          	lui	a5,0x54495
    80200408:	d4578793          	addi	a5,a5,-699 # 54494d45 <_skernel-0x2bd6b2bb>
    8020040c:	fcf43c23          	sd	a5,-40(s0)
    uint64_t sbi_set_timer_fid = 0;
    80200410:	fc043823          	sd	zero,-48(s0)
    return sbi_ecall(sbi_set_timer_eid, sbi_set_timer_fid, stime_value, 0, 0, 0, 0, 0);
    80200414:	00000893          	li	a7,0
    80200418:	00000813          	li	a6,0
    8020041c:	00000793          	li	a5,0
    80200420:	00000713          	li	a4,0
    80200424:	00000693          	li	a3,0
    80200428:	fb843603          	ld	a2,-72(s0)
    8020042c:	fd043583          	ld	a1,-48(s0)
    80200430:	fd843503          	ld	a0,-40(s0)
    80200434:	d99ff0ef          	jal	802001cc <sbi_ecall>
    80200438:	00050713          	mv	a4,a0
    8020043c:	00058793          	mv	a5,a1
    80200440:	fce43023          	sd	a4,-64(s0)
    80200444:	fcf43423          	sd	a5,-56(s0)
    80200448:	fc043703          	ld	a4,-64(s0)
    8020044c:	fc843783          	ld	a5,-56(s0)
    80200450:	00070913          	mv	s2,a4
    80200454:	00078993          	mv	s3,a5
    80200458:	00090713          	mv	a4,s2
    8020045c:	00098793          	mv	a5,s3
    80200460:	00070513          	mv	a0,a4
    80200464:	00078593          	mv	a1,a5
    80200468:	04813083          	ld	ra,72(sp)
    8020046c:	04013403          	ld	s0,64(sp)
    80200470:	03813903          	ld	s2,56(sp)
    80200474:	03013983          	ld	s3,48(sp)
    80200478:	05010113          	addi	sp,sp,80
    8020047c:	00008067          	ret

0000000080200480 <trap_handler>:
#include "stdint.h"
#include "printk.h"
#include "defs.h"
extern void clock_set_next_event(void);

void trap_handler(uint64_t scause, uint64_t sepc) {
    80200480:	fc010113          	addi	sp,sp,-64
    80200484:	02113c23          	sd	ra,56(sp)
    80200488:	02813823          	sd	s0,48(sp)
    8020048c:	04010413          	addi	s0,sp,64
    80200490:	fca43423          	sd	a0,-56(s0)
    80200494:	fcb43023          	sd	a1,-64(s0)

    // printk("in trap, the value pf sstatus is %llx \n", csr_read(sstatus));

    // 通过 `scause` 判断 trap 类型
    bool interrupt = (scause >> 63);
    80200498:	fc843783          	ld	a5,-56(s0)
    8020049c:	03f7d793          	srli	a5,a5,0x3f
    802004a0:	00f037b3          	snez	a5,a5
    802004a4:	fef407a3          	sb	a5,-17(s0)
    
    // 如果是 interrupt 判断是否是 timer interrupt
    uint64_t exception_code = scause & 0x7fffffff;
    802004a8:	fc843703          	ld	a4,-56(s0)
    802004ac:	800007b7          	lui	a5,0x80000
    802004b0:	fff7c793          	not	a5,a5
    802004b4:	00f777b3          	and	a5,a4,a5
    802004b8:	fef43023          	sd	a5,-32(s0)
    bool timer_interrupt = interrupt & (exception_code == 5);
    802004bc:	fef44783          	lbu	a5,-17(s0)
    802004c0:	0007871b          	sext.w	a4,a5
    802004c4:	fe043783          	ld	a5,-32(s0)
    802004c8:	ffb78793          	addi	a5,a5,-5 # ffffffff7ffffffb <_ebss+0xfffffffeffdfaffb>
    802004cc:	0017b793          	seqz	a5,a5
    802004d0:	0ff7f793          	zext.b	a5,a5
    802004d4:	0007879b          	sext.w	a5,a5
    802004d8:	00f777b3          	and	a5,a4,a5
    802004dc:	0007879b          	sext.w	a5,a5
    802004e0:	00f037b3          	snez	a5,a5
    802004e4:	fcf40fa3          	sb	a5,-33(s0)
    
    // 如果是 timer interrupt 则打印输出相关信息，并通过 `clock_set_next_event()` 设置下一次时钟中断
    // printk("interrupt is %d, exception_code is %d\n", interrupt, exception_code);
    if (timer_interrupt) {
    802004e8:	fdf44783          	lbu	a5,-33(s0)
    802004ec:	0ff7f793          	zext.b	a5,a5
    802004f0:	00078c63          	beqz	a5,80200508 <trap_handler+0x88>
        printk("[S] Supervisor Mode Timer Interrupt\n");
    802004f4:	00002517          	auipc	a0,0x2
    802004f8:	b0c50513          	addi	a0,a0,-1268 # 80202000 <_srodata>
    802004fc:	791000ef          	jal	8020148c <printk>
    
        // `clock_set_next_event()` 见 4.3.4 节
        clock_set_next_event();
    80200500:	c85ff0ef          	jal	80200184 <clock_set_next_event>
        // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试
        printk("%llx, %d, %llx, %d\n", scause, interrupt, exception_code, timer_interrupt);
        printk("test: 802005a8 >> 63 = %llx\n", 0x802005a8 >> 63);
    }
    // #error Unimplemented
    80200504:	03c0006f          	j	80200540 <trap_handler+0xc0>
        printk("%llx, %d, %llx, %d\n", scause, interrupt, exception_code, timer_interrupt);
    80200508:	fef44783          	lbu	a5,-17(s0)
    8020050c:	0007879b          	sext.w	a5,a5
    80200510:	fdf44703          	lbu	a4,-33(s0)
    80200514:	0007071b          	sext.w	a4,a4
    80200518:	fe043683          	ld	a3,-32(s0)
    8020051c:	00078613          	mv	a2,a5
    80200520:	fc843583          	ld	a1,-56(s0)
    80200524:	00002517          	auipc	a0,0x2
    80200528:	b0450513          	addi	a0,a0,-1276 # 80202028 <_srodata+0x28>
    8020052c:	761000ef          	jal	8020148c <printk>
        printk("test: 802005a8 >> 63 = %llx\n", 0x802005a8 >> 63);
    80200530:	00000593          	li	a1,0
    80200534:	00002517          	auipc	a0,0x2
    80200538:	b0c50513          	addi	a0,a0,-1268 # 80202040 <_srodata+0x40>
    8020053c:	751000ef          	jal	8020148c <printk>
    80200540:	00000013          	nop
    80200544:	03813083          	ld	ra,56(sp)
    80200548:	03013403          	ld	s0,48(sp)
    8020054c:	04010113          	addi	sp,sp,64
    80200550:	00008067          	ret

0000000080200554 <start_kernel>:
#include "printk.h"
#include "defs.h"
extern void test();

int start_kernel() {
    80200554:	fe010113          	addi	sp,sp,-32
    80200558:	00113c23          	sd	ra,24(sp)
    8020055c:	00813823          	sd	s0,16(sp)
    80200560:	02010413          	addi	s0,sp,32
    printk("2024");
    80200564:	00002517          	auipc	a0,0x2
    80200568:	afc50513          	addi	a0,a0,-1284 # 80202060 <_srodata+0x60>
    8020056c:	721000ef          	jal	8020148c <printk>
    printk(" ZJU Operating System\n");
    80200570:	00002517          	auipc	a0,0x2
    80200574:	af850513          	addi	a0,a0,-1288 # 80202068 <_srodata+0x68>
    80200578:	715000ef          	jal	8020148c <printk>

    // printk("before writing into the sscratch, the value is 0x%llx\n", csr_read(sscratch));
    csr_write(sscratch, 0x1);
    8020057c:	00100793          	li	a5,1
    80200580:	fef43423          	sd	a5,-24(s0)
    80200584:	fe843783          	ld	a5,-24(s0)
    80200588:	14079073          	csrw	sscratch,a5
    // printk("after writing into the sscratch, the value is 0x%llx\n", csr_read(sscratch));

    test();
    8020058c:	01c000ef          	jal	802005a8 <test>
    return 0;
    80200590:	00000793          	li	a5,0
}
    80200594:	00078513          	mv	a0,a5
    80200598:	01813083          	ld	ra,24(sp)
    8020059c:	01013403          	ld	s0,16(sp)
    802005a0:	02010113          	addi	sp,sp,32
    802005a4:	00008067          	ret

00000000802005a8 <test>:
#include "printk.h"
#include "defs.h"
void test() {
    802005a8:	fe010113          	addi	sp,sp,-32
    802005ac:	00113c23          	sd	ra,24(sp)
    802005b0:	00813823          	sd	s0,16(sp)
    802005b4:	02010413          	addi	s0,sp,32
    int i = 0;
    802005b8:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
    802005bc:	fec42783          	lw	a5,-20(s0)
    802005c0:	0017879b          	addiw	a5,a5,1
    802005c4:	fef42623          	sw	a5,-20(s0)
    802005c8:	fec42783          	lw	a5,-20(s0)
    802005cc:	00078713          	mv	a4,a5
    802005d0:	05f5e7b7          	lui	a5,0x5f5e
    802005d4:	1007879b          	addiw	a5,a5,256 # 5f5e100 <_skernel-0x7a2a1f00>
    802005d8:	02f767bb          	remw	a5,a4,a5
    802005dc:	0007879b          	sext.w	a5,a5
    802005e0:	fc079ee3          	bnez	a5,802005bc <test+0x14>
            // printk("in test, the value of sstatus is %llx \n", csr_read(sstatus));
            printk("kernel is running!\n");
    802005e4:	00002517          	auipc	a0,0x2
    802005e8:	a9c50513          	addi	a0,a0,-1380 # 80202080 <_srodata+0x80>
    802005ec:	6a1000ef          	jal	8020148c <printk>
            i = 0;
    802005f0:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
    802005f4:	fc9ff06f          	j	802005bc <test+0x14>

00000000802005f8 <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
    802005f8:	fe010113          	addi	sp,sp,-32
    802005fc:	00113c23          	sd	ra,24(sp)
    80200600:	00813823          	sd	s0,16(sp)
    80200604:	02010413          	addi	s0,sp,32
    80200608:	00050793          	mv	a5,a0
    8020060c:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
    80200610:	fec42783          	lw	a5,-20(s0)
    80200614:	0ff7f793          	zext.b	a5,a5
    80200618:	00078513          	mv	a0,a5
    8020061c:	c85ff0ef          	jal	802002a0 <sbi_debug_console_write_byte>
    return (char)c;
    80200620:	fec42783          	lw	a5,-20(s0)
    80200624:	0ff7f793          	zext.b	a5,a5
    80200628:	0007879b          	sext.w	a5,a5
}
    8020062c:	00078513          	mv	a0,a5
    80200630:	01813083          	ld	ra,24(sp)
    80200634:	01013403          	ld	s0,16(sp)
    80200638:	02010113          	addi	sp,sp,32
    8020063c:	00008067          	ret

0000000080200640 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
    80200640:	fe010113          	addi	sp,sp,-32
    80200644:	00813c23          	sd	s0,24(sp)
    80200648:	02010413          	addi	s0,sp,32
    8020064c:	00050793          	mv	a5,a0
    80200650:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
    80200654:	fec42783          	lw	a5,-20(s0)
    80200658:	0007871b          	sext.w	a4,a5
    8020065c:	02000793          	li	a5,32
    80200660:	02f70263          	beq	a4,a5,80200684 <isspace+0x44>
    80200664:	fec42783          	lw	a5,-20(s0)
    80200668:	0007871b          	sext.w	a4,a5
    8020066c:	00800793          	li	a5,8
    80200670:	00e7de63          	bge	a5,a4,8020068c <isspace+0x4c>
    80200674:	fec42783          	lw	a5,-20(s0)
    80200678:	0007871b          	sext.w	a4,a5
    8020067c:	00d00793          	li	a5,13
    80200680:	00e7c663          	blt	a5,a4,8020068c <isspace+0x4c>
    80200684:	00100793          	li	a5,1
    80200688:	0080006f          	j	80200690 <isspace+0x50>
    8020068c:	00000793          	li	a5,0
}
    80200690:	00078513          	mv	a0,a5
    80200694:	01813403          	ld	s0,24(sp)
    80200698:	02010113          	addi	sp,sp,32
    8020069c:	00008067          	ret

00000000802006a0 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
    802006a0:	fb010113          	addi	sp,sp,-80
    802006a4:	04113423          	sd	ra,72(sp)
    802006a8:	04813023          	sd	s0,64(sp)
    802006ac:	05010413          	addi	s0,sp,80
    802006b0:	fca43423          	sd	a0,-56(s0)
    802006b4:	fcb43023          	sd	a1,-64(s0)
    802006b8:	00060793          	mv	a5,a2
    802006bc:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
    802006c0:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
    802006c4:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
    802006c8:	fc843783          	ld	a5,-56(s0)
    802006cc:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
    802006d0:	0100006f          	j	802006e0 <strtol+0x40>
        p++;
    802006d4:	fd843783          	ld	a5,-40(s0)
    802006d8:	00178793          	addi	a5,a5,1
    802006dc:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
    802006e0:	fd843783          	ld	a5,-40(s0)
    802006e4:	0007c783          	lbu	a5,0(a5)
    802006e8:	0007879b          	sext.w	a5,a5
    802006ec:	00078513          	mv	a0,a5
    802006f0:	f51ff0ef          	jal	80200640 <isspace>
    802006f4:	00050793          	mv	a5,a0
    802006f8:	fc079ee3          	bnez	a5,802006d4 <strtol+0x34>
    }

    if (*p == '-') {
    802006fc:	fd843783          	ld	a5,-40(s0)
    80200700:	0007c783          	lbu	a5,0(a5)
    80200704:	00078713          	mv	a4,a5
    80200708:	02d00793          	li	a5,45
    8020070c:	00f71e63          	bne	a4,a5,80200728 <strtol+0x88>
        neg = true;
    80200710:	00100793          	li	a5,1
    80200714:	fef403a3          	sb	a5,-25(s0)
        p++;
    80200718:	fd843783          	ld	a5,-40(s0)
    8020071c:	00178793          	addi	a5,a5,1
    80200720:	fcf43c23          	sd	a5,-40(s0)
    80200724:	0240006f          	j	80200748 <strtol+0xa8>
    } else if (*p == '+') {
    80200728:	fd843783          	ld	a5,-40(s0)
    8020072c:	0007c783          	lbu	a5,0(a5)
    80200730:	00078713          	mv	a4,a5
    80200734:	02b00793          	li	a5,43
    80200738:	00f71863          	bne	a4,a5,80200748 <strtol+0xa8>
        p++;
    8020073c:	fd843783          	ld	a5,-40(s0)
    80200740:	00178793          	addi	a5,a5,1
    80200744:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
    80200748:	fbc42783          	lw	a5,-68(s0)
    8020074c:	0007879b          	sext.w	a5,a5
    80200750:	06079c63          	bnez	a5,802007c8 <strtol+0x128>
        if (*p == '0') {
    80200754:	fd843783          	ld	a5,-40(s0)
    80200758:	0007c783          	lbu	a5,0(a5)
    8020075c:	00078713          	mv	a4,a5
    80200760:	03000793          	li	a5,48
    80200764:	04f71e63          	bne	a4,a5,802007c0 <strtol+0x120>
            p++;
    80200768:	fd843783          	ld	a5,-40(s0)
    8020076c:	00178793          	addi	a5,a5,1
    80200770:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
    80200774:	fd843783          	ld	a5,-40(s0)
    80200778:	0007c783          	lbu	a5,0(a5)
    8020077c:	00078713          	mv	a4,a5
    80200780:	07800793          	li	a5,120
    80200784:	00f70c63          	beq	a4,a5,8020079c <strtol+0xfc>
    80200788:	fd843783          	ld	a5,-40(s0)
    8020078c:	0007c783          	lbu	a5,0(a5)
    80200790:	00078713          	mv	a4,a5
    80200794:	05800793          	li	a5,88
    80200798:	00f71e63          	bne	a4,a5,802007b4 <strtol+0x114>
                base = 16;
    8020079c:	01000793          	li	a5,16
    802007a0:	faf42e23          	sw	a5,-68(s0)
                p++;
    802007a4:	fd843783          	ld	a5,-40(s0)
    802007a8:	00178793          	addi	a5,a5,1
    802007ac:	fcf43c23          	sd	a5,-40(s0)
    802007b0:	0180006f          	j	802007c8 <strtol+0x128>
            } else {
                base = 8;
    802007b4:	00800793          	li	a5,8
    802007b8:	faf42e23          	sw	a5,-68(s0)
    802007bc:	00c0006f          	j	802007c8 <strtol+0x128>
            }
        } else {
            base = 10;
    802007c0:	00a00793          	li	a5,10
    802007c4:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
    802007c8:	fd843783          	ld	a5,-40(s0)
    802007cc:	0007c783          	lbu	a5,0(a5)
    802007d0:	00078713          	mv	a4,a5
    802007d4:	02f00793          	li	a5,47
    802007d8:	02e7f863          	bgeu	a5,a4,80200808 <strtol+0x168>
    802007dc:	fd843783          	ld	a5,-40(s0)
    802007e0:	0007c783          	lbu	a5,0(a5)
    802007e4:	00078713          	mv	a4,a5
    802007e8:	03900793          	li	a5,57
    802007ec:	00e7ee63          	bltu	a5,a4,80200808 <strtol+0x168>
            digit = *p - '0';
    802007f0:	fd843783          	ld	a5,-40(s0)
    802007f4:	0007c783          	lbu	a5,0(a5)
    802007f8:	0007879b          	sext.w	a5,a5
    802007fc:	fd07879b          	addiw	a5,a5,-48
    80200800:	fcf42a23          	sw	a5,-44(s0)
    80200804:	0800006f          	j	80200884 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
    80200808:	fd843783          	ld	a5,-40(s0)
    8020080c:	0007c783          	lbu	a5,0(a5)
    80200810:	00078713          	mv	a4,a5
    80200814:	06000793          	li	a5,96
    80200818:	02e7f863          	bgeu	a5,a4,80200848 <strtol+0x1a8>
    8020081c:	fd843783          	ld	a5,-40(s0)
    80200820:	0007c783          	lbu	a5,0(a5)
    80200824:	00078713          	mv	a4,a5
    80200828:	07a00793          	li	a5,122
    8020082c:	00e7ee63          	bltu	a5,a4,80200848 <strtol+0x1a8>
            digit = *p - ('a' - 10);
    80200830:	fd843783          	ld	a5,-40(s0)
    80200834:	0007c783          	lbu	a5,0(a5)
    80200838:	0007879b          	sext.w	a5,a5
    8020083c:	fa97879b          	addiw	a5,a5,-87
    80200840:	fcf42a23          	sw	a5,-44(s0)
    80200844:	0400006f          	j	80200884 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
    80200848:	fd843783          	ld	a5,-40(s0)
    8020084c:	0007c783          	lbu	a5,0(a5)
    80200850:	00078713          	mv	a4,a5
    80200854:	04000793          	li	a5,64
    80200858:	06e7f863          	bgeu	a5,a4,802008c8 <strtol+0x228>
    8020085c:	fd843783          	ld	a5,-40(s0)
    80200860:	0007c783          	lbu	a5,0(a5)
    80200864:	00078713          	mv	a4,a5
    80200868:	05a00793          	li	a5,90
    8020086c:	04e7ee63          	bltu	a5,a4,802008c8 <strtol+0x228>
            digit = *p - ('A' - 10);
    80200870:	fd843783          	ld	a5,-40(s0)
    80200874:	0007c783          	lbu	a5,0(a5)
    80200878:	0007879b          	sext.w	a5,a5
    8020087c:	fc97879b          	addiw	a5,a5,-55
    80200880:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
    80200884:	fd442783          	lw	a5,-44(s0)
    80200888:	00078713          	mv	a4,a5
    8020088c:	fbc42783          	lw	a5,-68(s0)
    80200890:	0007071b          	sext.w	a4,a4
    80200894:	0007879b          	sext.w	a5,a5
    80200898:	02f75663          	bge	a4,a5,802008c4 <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
    8020089c:	fbc42703          	lw	a4,-68(s0)
    802008a0:	fe843783          	ld	a5,-24(s0)
    802008a4:	02f70733          	mul	a4,a4,a5
    802008a8:	fd442783          	lw	a5,-44(s0)
    802008ac:	00f707b3          	add	a5,a4,a5
    802008b0:	fef43423          	sd	a5,-24(s0)
        p++;
    802008b4:	fd843783          	ld	a5,-40(s0)
    802008b8:	00178793          	addi	a5,a5,1
    802008bc:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
    802008c0:	f09ff06f          	j	802007c8 <strtol+0x128>
            break;
    802008c4:	00000013          	nop
    }

    if (endptr) {
    802008c8:	fc043783          	ld	a5,-64(s0)
    802008cc:	00078863          	beqz	a5,802008dc <strtol+0x23c>
        *endptr = (char *)p;
    802008d0:	fc043783          	ld	a5,-64(s0)
    802008d4:	fd843703          	ld	a4,-40(s0)
    802008d8:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
    802008dc:	fe744783          	lbu	a5,-25(s0)
    802008e0:	0ff7f793          	zext.b	a5,a5
    802008e4:	00078863          	beqz	a5,802008f4 <strtol+0x254>
    802008e8:	fe843783          	ld	a5,-24(s0)
    802008ec:	40f007b3          	neg	a5,a5
    802008f0:	0080006f          	j	802008f8 <strtol+0x258>
    802008f4:	fe843783          	ld	a5,-24(s0)
}
    802008f8:	00078513          	mv	a0,a5
    802008fc:	04813083          	ld	ra,72(sp)
    80200900:	04013403          	ld	s0,64(sp)
    80200904:	05010113          	addi	sp,sp,80
    80200908:	00008067          	ret

000000008020090c <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
    8020090c:	fd010113          	addi	sp,sp,-48
    80200910:	02113423          	sd	ra,40(sp)
    80200914:	02813023          	sd	s0,32(sp)
    80200918:	03010413          	addi	s0,sp,48
    8020091c:	fca43c23          	sd	a0,-40(s0)
    80200920:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
    80200924:	fd043783          	ld	a5,-48(s0)
    80200928:	00079863          	bnez	a5,80200938 <puts_wo_nl+0x2c>
        s = "(null)";
    8020092c:	00001797          	auipc	a5,0x1
    80200930:	76c78793          	addi	a5,a5,1900 # 80202098 <_srodata+0x98>
    80200934:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
    80200938:	fd043783          	ld	a5,-48(s0)
    8020093c:	fef43423          	sd	a5,-24(s0)
    while (*p) {
    80200940:	0240006f          	j	80200964 <puts_wo_nl+0x58>
        putch(*p++);
    80200944:	fe843783          	ld	a5,-24(s0)
    80200948:	00178713          	addi	a4,a5,1
    8020094c:	fee43423          	sd	a4,-24(s0)
    80200950:	0007c783          	lbu	a5,0(a5)
    80200954:	0007871b          	sext.w	a4,a5
    80200958:	fd843783          	ld	a5,-40(s0)
    8020095c:	00070513          	mv	a0,a4
    80200960:	000780e7          	jalr	a5
    while (*p) {
    80200964:	fe843783          	ld	a5,-24(s0)
    80200968:	0007c783          	lbu	a5,0(a5)
    8020096c:	fc079ce3          	bnez	a5,80200944 <puts_wo_nl+0x38>
    }
    return p - s;
    80200970:	fe843703          	ld	a4,-24(s0)
    80200974:	fd043783          	ld	a5,-48(s0)
    80200978:	40f707b3          	sub	a5,a4,a5
    8020097c:	0007879b          	sext.w	a5,a5
}
    80200980:	00078513          	mv	a0,a5
    80200984:	02813083          	ld	ra,40(sp)
    80200988:	02013403          	ld	s0,32(sp)
    8020098c:	03010113          	addi	sp,sp,48
    80200990:	00008067          	ret

0000000080200994 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
    80200994:	f9010113          	addi	sp,sp,-112
    80200998:	06113423          	sd	ra,104(sp)
    8020099c:	06813023          	sd	s0,96(sp)
    802009a0:	07010413          	addi	s0,sp,112
    802009a4:	faa43423          	sd	a0,-88(s0)
    802009a8:	fab43023          	sd	a1,-96(s0)
    802009ac:	00060793          	mv	a5,a2
    802009b0:	f8d43823          	sd	a3,-112(s0)
    802009b4:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
    802009b8:	f9f44783          	lbu	a5,-97(s0)
    802009bc:	0ff7f793          	zext.b	a5,a5
    802009c0:	02078663          	beqz	a5,802009ec <print_dec_int+0x58>
    802009c4:	fa043703          	ld	a4,-96(s0)
    802009c8:	fff00793          	li	a5,-1
    802009cc:	03f79793          	slli	a5,a5,0x3f
    802009d0:	00f71e63          	bne	a4,a5,802009ec <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
    802009d4:	00001597          	auipc	a1,0x1
    802009d8:	6cc58593          	addi	a1,a1,1740 # 802020a0 <_srodata+0xa0>
    802009dc:	fa843503          	ld	a0,-88(s0)
    802009e0:	f2dff0ef          	jal	8020090c <puts_wo_nl>
    802009e4:	00050793          	mv	a5,a0
    802009e8:	2a00006f          	j	80200c88 <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
    802009ec:	f9043783          	ld	a5,-112(s0)
    802009f0:	00c7a783          	lw	a5,12(a5)
    802009f4:	00079a63          	bnez	a5,80200a08 <print_dec_int+0x74>
    802009f8:	fa043783          	ld	a5,-96(s0)
    802009fc:	00079663          	bnez	a5,80200a08 <print_dec_int+0x74>
        return 0;
    80200a00:	00000793          	li	a5,0
    80200a04:	2840006f          	j	80200c88 <print_dec_int+0x2f4>
    }

    bool neg = false;
    80200a08:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
    80200a0c:	f9f44783          	lbu	a5,-97(s0)
    80200a10:	0ff7f793          	zext.b	a5,a5
    80200a14:	02078063          	beqz	a5,80200a34 <print_dec_int+0xa0>
    80200a18:	fa043783          	ld	a5,-96(s0)
    80200a1c:	0007dc63          	bgez	a5,80200a34 <print_dec_int+0xa0>
        neg = true;
    80200a20:	00100793          	li	a5,1
    80200a24:	fef407a3          	sb	a5,-17(s0)
        num = -num;
    80200a28:	fa043783          	ld	a5,-96(s0)
    80200a2c:	40f007b3          	neg	a5,a5
    80200a30:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
    80200a34:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
    80200a38:	f9f44783          	lbu	a5,-97(s0)
    80200a3c:	0ff7f793          	zext.b	a5,a5
    80200a40:	02078863          	beqz	a5,80200a70 <print_dec_int+0xdc>
    80200a44:	fef44783          	lbu	a5,-17(s0)
    80200a48:	0ff7f793          	zext.b	a5,a5
    80200a4c:	00079e63          	bnez	a5,80200a68 <print_dec_int+0xd4>
    80200a50:	f9043783          	ld	a5,-112(s0)
    80200a54:	0057c783          	lbu	a5,5(a5)
    80200a58:	00079863          	bnez	a5,80200a68 <print_dec_int+0xd4>
    80200a5c:	f9043783          	ld	a5,-112(s0)
    80200a60:	0047c783          	lbu	a5,4(a5)
    80200a64:	00078663          	beqz	a5,80200a70 <print_dec_int+0xdc>
    80200a68:	00100793          	li	a5,1
    80200a6c:	0080006f          	j	80200a74 <print_dec_int+0xe0>
    80200a70:	00000793          	li	a5,0
    80200a74:	fcf40ba3          	sb	a5,-41(s0)
    80200a78:	fd744783          	lbu	a5,-41(s0)
    80200a7c:	0017f793          	andi	a5,a5,1
    80200a80:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
    80200a84:	fa043703          	ld	a4,-96(s0)
    80200a88:	00a00793          	li	a5,10
    80200a8c:	02f777b3          	remu	a5,a4,a5
    80200a90:	0ff7f713          	zext.b	a4,a5
    80200a94:	fe842783          	lw	a5,-24(s0)
    80200a98:	0017869b          	addiw	a3,a5,1
    80200a9c:	fed42423          	sw	a3,-24(s0)
    80200aa0:	0307071b          	addiw	a4,a4,48
    80200aa4:	0ff77713          	zext.b	a4,a4
    80200aa8:	ff078793          	addi	a5,a5,-16
    80200aac:	008787b3          	add	a5,a5,s0
    80200ab0:	fce78423          	sb	a4,-56(a5)
        num /= 10;
    80200ab4:	fa043703          	ld	a4,-96(s0)
    80200ab8:	00a00793          	li	a5,10
    80200abc:	02f757b3          	divu	a5,a4,a5
    80200ac0:	faf43023          	sd	a5,-96(s0)
    } while (num);
    80200ac4:	fa043783          	ld	a5,-96(s0)
    80200ac8:	fa079ee3          	bnez	a5,80200a84 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
    80200acc:	f9043783          	ld	a5,-112(s0)
    80200ad0:	00c7a783          	lw	a5,12(a5)
    80200ad4:	00078713          	mv	a4,a5
    80200ad8:	fff00793          	li	a5,-1
    80200adc:	02f71063          	bne	a4,a5,80200afc <print_dec_int+0x168>
    80200ae0:	f9043783          	ld	a5,-112(s0)
    80200ae4:	0037c783          	lbu	a5,3(a5)
    80200ae8:	00078a63          	beqz	a5,80200afc <print_dec_int+0x168>
        flags->prec = flags->width;
    80200aec:	f9043783          	ld	a5,-112(s0)
    80200af0:	0087a703          	lw	a4,8(a5)
    80200af4:	f9043783          	ld	a5,-112(s0)
    80200af8:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
    80200afc:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80200b00:	f9043783          	ld	a5,-112(s0)
    80200b04:	0087a703          	lw	a4,8(a5)
    80200b08:	fe842783          	lw	a5,-24(s0)
    80200b0c:	fcf42823          	sw	a5,-48(s0)
    80200b10:	f9043783          	ld	a5,-112(s0)
    80200b14:	00c7a783          	lw	a5,12(a5)
    80200b18:	fcf42623          	sw	a5,-52(s0)
    80200b1c:	fd042783          	lw	a5,-48(s0)
    80200b20:	00078593          	mv	a1,a5
    80200b24:	fcc42783          	lw	a5,-52(s0)
    80200b28:	00078613          	mv	a2,a5
    80200b2c:	0006069b          	sext.w	a3,a2
    80200b30:	0005879b          	sext.w	a5,a1
    80200b34:	00f6d463          	bge	a3,a5,80200b3c <print_dec_int+0x1a8>
    80200b38:	00058613          	mv	a2,a1
    80200b3c:	0006079b          	sext.w	a5,a2
    80200b40:	40f707bb          	subw	a5,a4,a5
    80200b44:	0007871b          	sext.w	a4,a5
    80200b48:	fd744783          	lbu	a5,-41(s0)
    80200b4c:	0007879b          	sext.w	a5,a5
    80200b50:	40f707bb          	subw	a5,a4,a5
    80200b54:	fef42023          	sw	a5,-32(s0)
    80200b58:	0280006f          	j	80200b80 <print_dec_int+0x1ec>
        putch(' ');
    80200b5c:	fa843783          	ld	a5,-88(s0)
    80200b60:	02000513          	li	a0,32
    80200b64:	000780e7          	jalr	a5
        ++written;
    80200b68:	fe442783          	lw	a5,-28(s0)
    80200b6c:	0017879b          	addiw	a5,a5,1
    80200b70:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80200b74:	fe042783          	lw	a5,-32(s0)
    80200b78:	fff7879b          	addiw	a5,a5,-1
    80200b7c:	fef42023          	sw	a5,-32(s0)
    80200b80:	fe042783          	lw	a5,-32(s0)
    80200b84:	0007879b          	sext.w	a5,a5
    80200b88:	fcf04ae3          	bgtz	a5,80200b5c <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
    80200b8c:	fd744783          	lbu	a5,-41(s0)
    80200b90:	0ff7f793          	zext.b	a5,a5
    80200b94:	04078463          	beqz	a5,80200bdc <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
    80200b98:	fef44783          	lbu	a5,-17(s0)
    80200b9c:	0ff7f793          	zext.b	a5,a5
    80200ba0:	00078663          	beqz	a5,80200bac <print_dec_int+0x218>
    80200ba4:	02d00793          	li	a5,45
    80200ba8:	01c0006f          	j	80200bc4 <print_dec_int+0x230>
    80200bac:	f9043783          	ld	a5,-112(s0)
    80200bb0:	0057c783          	lbu	a5,5(a5)
    80200bb4:	00078663          	beqz	a5,80200bc0 <print_dec_int+0x22c>
    80200bb8:	02b00793          	li	a5,43
    80200bbc:	0080006f          	j	80200bc4 <print_dec_int+0x230>
    80200bc0:	02000793          	li	a5,32
    80200bc4:	fa843703          	ld	a4,-88(s0)
    80200bc8:	00078513          	mv	a0,a5
    80200bcc:	000700e7          	jalr	a4
        ++written;
    80200bd0:	fe442783          	lw	a5,-28(s0)
    80200bd4:	0017879b          	addiw	a5,a5,1
    80200bd8:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80200bdc:	fe842783          	lw	a5,-24(s0)
    80200be0:	fcf42e23          	sw	a5,-36(s0)
    80200be4:	0280006f          	j	80200c0c <print_dec_int+0x278>
        putch('0');
    80200be8:	fa843783          	ld	a5,-88(s0)
    80200bec:	03000513          	li	a0,48
    80200bf0:	000780e7          	jalr	a5
        ++written;
    80200bf4:	fe442783          	lw	a5,-28(s0)
    80200bf8:	0017879b          	addiw	a5,a5,1
    80200bfc:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80200c00:	fdc42783          	lw	a5,-36(s0)
    80200c04:	0017879b          	addiw	a5,a5,1
    80200c08:	fcf42e23          	sw	a5,-36(s0)
    80200c0c:	f9043783          	ld	a5,-112(s0)
    80200c10:	00c7a703          	lw	a4,12(a5)
    80200c14:	fd744783          	lbu	a5,-41(s0)
    80200c18:	0007879b          	sext.w	a5,a5
    80200c1c:	40f707bb          	subw	a5,a4,a5
    80200c20:	0007871b          	sext.w	a4,a5
    80200c24:	fdc42783          	lw	a5,-36(s0)
    80200c28:	0007879b          	sext.w	a5,a5
    80200c2c:	fae7cee3          	blt	a5,a4,80200be8 <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
    80200c30:	fe842783          	lw	a5,-24(s0)
    80200c34:	fff7879b          	addiw	a5,a5,-1
    80200c38:	fcf42c23          	sw	a5,-40(s0)
    80200c3c:	03c0006f          	j	80200c78 <print_dec_int+0x2e4>
        putch(buf[i]);
    80200c40:	fd842783          	lw	a5,-40(s0)
    80200c44:	ff078793          	addi	a5,a5,-16
    80200c48:	008787b3          	add	a5,a5,s0
    80200c4c:	fc87c783          	lbu	a5,-56(a5)
    80200c50:	0007871b          	sext.w	a4,a5
    80200c54:	fa843783          	ld	a5,-88(s0)
    80200c58:	00070513          	mv	a0,a4
    80200c5c:	000780e7          	jalr	a5
        ++written;
    80200c60:	fe442783          	lw	a5,-28(s0)
    80200c64:	0017879b          	addiw	a5,a5,1
    80200c68:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
    80200c6c:	fd842783          	lw	a5,-40(s0)
    80200c70:	fff7879b          	addiw	a5,a5,-1
    80200c74:	fcf42c23          	sw	a5,-40(s0)
    80200c78:	fd842783          	lw	a5,-40(s0)
    80200c7c:	0007879b          	sext.w	a5,a5
    80200c80:	fc07d0e3          	bgez	a5,80200c40 <print_dec_int+0x2ac>
    }

    return written;
    80200c84:	fe442783          	lw	a5,-28(s0)
}
    80200c88:	00078513          	mv	a0,a5
    80200c8c:	06813083          	ld	ra,104(sp)
    80200c90:	06013403          	ld	s0,96(sp)
    80200c94:	07010113          	addi	sp,sp,112
    80200c98:	00008067          	ret

0000000080200c9c <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
    80200c9c:	f4010113          	addi	sp,sp,-192
    80200ca0:	0a113c23          	sd	ra,184(sp)
    80200ca4:	0a813823          	sd	s0,176(sp)
    80200ca8:	0c010413          	addi	s0,sp,192
    80200cac:	f4a43c23          	sd	a0,-168(s0)
    80200cb0:	f4b43823          	sd	a1,-176(s0)
    80200cb4:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
    80200cb8:	f8043023          	sd	zero,-128(s0)
    80200cbc:	f8043423          	sd	zero,-120(s0)

    int written = 0;
    80200cc0:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
    80200cc4:	7a40006f          	j	80201468 <vprintfmt+0x7cc>
        if (flags.in_format) {
    80200cc8:	f8044783          	lbu	a5,-128(s0)
    80200ccc:	72078e63          	beqz	a5,80201408 <vprintfmt+0x76c>
            if (*fmt == '#') {
    80200cd0:	f5043783          	ld	a5,-176(s0)
    80200cd4:	0007c783          	lbu	a5,0(a5)
    80200cd8:	00078713          	mv	a4,a5
    80200cdc:	02300793          	li	a5,35
    80200ce0:	00f71863          	bne	a4,a5,80200cf0 <vprintfmt+0x54>
                flags.sharpflag = true;
    80200ce4:	00100793          	li	a5,1
    80200ce8:	f8f40123          	sb	a5,-126(s0)
    80200cec:	7700006f          	j	8020145c <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
    80200cf0:	f5043783          	ld	a5,-176(s0)
    80200cf4:	0007c783          	lbu	a5,0(a5)
    80200cf8:	00078713          	mv	a4,a5
    80200cfc:	03000793          	li	a5,48
    80200d00:	00f71863          	bne	a4,a5,80200d10 <vprintfmt+0x74>
                flags.zeroflag = true;
    80200d04:	00100793          	li	a5,1
    80200d08:	f8f401a3          	sb	a5,-125(s0)
    80200d0c:	7500006f          	j	8020145c <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
    80200d10:	f5043783          	ld	a5,-176(s0)
    80200d14:	0007c783          	lbu	a5,0(a5)
    80200d18:	00078713          	mv	a4,a5
    80200d1c:	06c00793          	li	a5,108
    80200d20:	04f70063          	beq	a4,a5,80200d60 <vprintfmt+0xc4>
    80200d24:	f5043783          	ld	a5,-176(s0)
    80200d28:	0007c783          	lbu	a5,0(a5)
    80200d2c:	00078713          	mv	a4,a5
    80200d30:	07a00793          	li	a5,122
    80200d34:	02f70663          	beq	a4,a5,80200d60 <vprintfmt+0xc4>
    80200d38:	f5043783          	ld	a5,-176(s0)
    80200d3c:	0007c783          	lbu	a5,0(a5)
    80200d40:	00078713          	mv	a4,a5
    80200d44:	07400793          	li	a5,116
    80200d48:	00f70c63          	beq	a4,a5,80200d60 <vprintfmt+0xc4>
    80200d4c:	f5043783          	ld	a5,-176(s0)
    80200d50:	0007c783          	lbu	a5,0(a5)
    80200d54:	00078713          	mv	a4,a5
    80200d58:	06a00793          	li	a5,106
    80200d5c:	00f71863          	bne	a4,a5,80200d6c <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
    80200d60:	00100793          	li	a5,1
    80200d64:	f8f400a3          	sb	a5,-127(s0)
    80200d68:	6f40006f          	j	8020145c <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
    80200d6c:	f5043783          	ld	a5,-176(s0)
    80200d70:	0007c783          	lbu	a5,0(a5)
    80200d74:	00078713          	mv	a4,a5
    80200d78:	02b00793          	li	a5,43
    80200d7c:	00f71863          	bne	a4,a5,80200d8c <vprintfmt+0xf0>
                flags.sign = true;
    80200d80:	00100793          	li	a5,1
    80200d84:	f8f402a3          	sb	a5,-123(s0)
    80200d88:	6d40006f          	j	8020145c <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
    80200d8c:	f5043783          	ld	a5,-176(s0)
    80200d90:	0007c783          	lbu	a5,0(a5)
    80200d94:	00078713          	mv	a4,a5
    80200d98:	02000793          	li	a5,32
    80200d9c:	00f71863          	bne	a4,a5,80200dac <vprintfmt+0x110>
                flags.spaceflag = true;
    80200da0:	00100793          	li	a5,1
    80200da4:	f8f40223          	sb	a5,-124(s0)
    80200da8:	6b40006f          	j	8020145c <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
    80200dac:	f5043783          	ld	a5,-176(s0)
    80200db0:	0007c783          	lbu	a5,0(a5)
    80200db4:	00078713          	mv	a4,a5
    80200db8:	02a00793          	li	a5,42
    80200dbc:	00f71e63          	bne	a4,a5,80200dd8 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
    80200dc0:	f4843783          	ld	a5,-184(s0)
    80200dc4:	00878713          	addi	a4,a5,8
    80200dc8:	f4e43423          	sd	a4,-184(s0)
    80200dcc:	0007a783          	lw	a5,0(a5)
    80200dd0:	f8f42423          	sw	a5,-120(s0)
    80200dd4:	6880006f          	j	8020145c <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
    80200dd8:	f5043783          	ld	a5,-176(s0)
    80200ddc:	0007c783          	lbu	a5,0(a5)
    80200de0:	00078713          	mv	a4,a5
    80200de4:	03000793          	li	a5,48
    80200de8:	04e7f663          	bgeu	a5,a4,80200e34 <vprintfmt+0x198>
    80200dec:	f5043783          	ld	a5,-176(s0)
    80200df0:	0007c783          	lbu	a5,0(a5)
    80200df4:	00078713          	mv	a4,a5
    80200df8:	03900793          	li	a5,57
    80200dfc:	02e7ec63          	bltu	a5,a4,80200e34 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
    80200e00:	f5043783          	ld	a5,-176(s0)
    80200e04:	f5040713          	addi	a4,s0,-176
    80200e08:	00a00613          	li	a2,10
    80200e0c:	00070593          	mv	a1,a4
    80200e10:	00078513          	mv	a0,a5
    80200e14:	88dff0ef          	jal	802006a0 <strtol>
    80200e18:	00050793          	mv	a5,a0
    80200e1c:	0007879b          	sext.w	a5,a5
    80200e20:	f8f42423          	sw	a5,-120(s0)
                fmt--;
    80200e24:	f5043783          	ld	a5,-176(s0)
    80200e28:	fff78793          	addi	a5,a5,-1
    80200e2c:	f4f43823          	sd	a5,-176(s0)
    80200e30:	62c0006f          	j	8020145c <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
    80200e34:	f5043783          	ld	a5,-176(s0)
    80200e38:	0007c783          	lbu	a5,0(a5)
    80200e3c:	00078713          	mv	a4,a5
    80200e40:	02e00793          	li	a5,46
    80200e44:	06f71863          	bne	a4,a5,80200eb4 <vprintfmt+0x218>
                fmt++;
    80200e48:	f5043783          	ld	a5,-176(s0)
    80200e4c:	00178793          	addi	a5,a5,1
    80200e50:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
    80200e54:	f5043783          	ld	a5,-176(s0)
    80200e58:	0007c783          	lbu	a5,0(a5)
    80200e5c:	00078713          	mv	a4,a5
    80200e60:	02a00793          	li	a5,42
    80200e64:	00f71e63          	bne	a4,a5,80200e80 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
    80200e68:	f4843783          	ld	a5,-184(s0)
    80200e6c:	00878713          	addi	a4,a5,8
    80200e70:	f4e43423          	sd	a4,-184(s0)
    80200e74:	0007a783          	lw	a5,0(a5)
    80200e78:	f8f42623          	sw	a5,-116(s0)
    80200e7c:	5e00006f          	j	8020145c <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
    80200e80:	f5043783          	ld	a5,-176(s0)
    80200e84:	f5040713          	addi	a4,s0,-176
    80200e88:	00a00613          	li	a2,10
    80200e8c:	00070593          	mv	a1,a4
    80200e90:	00078513          	mv	a0,a5
    80200e94:	80dff0ef          	jal	802006a0 <strtol>
    80200e98:	00050793          	mv	a5,a0
    80200e9c:	0007879b          	sext.w	a5,a5
    80200ea0:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
    80200ea4:	f5043783          	ld	a5,-176(s0)
    80200ea8:	fff78793          	addi	a5,a5,-1
    80200eac:	f4f43823          	sd	a5,-176(s0)
    80200eb0:	5ac0006f          	j	8020145c <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    80200eb4:	f5043783          	ld	a5,-176(s0)
    80200eb8:	0007c783          	lbu	a5,0(a5)
    80200ebc:	00078713          	mv	a4,a5
    80200ec0:	07800793          	li	a5,120
    80200ec4:	02f70663          	beq	a4,a5,80200ef0 <vprintfmt+0x254>
    80200ec8:	f5043783          	ld	a5,-176(s0)
    80200ecc:	0007c783          	lbu	a5,0(a5)
    80200ed0:	00078713          	mv	a4,a5
    80200ed4:	05800793          	li	a5,88
    80200ed8:	00f70c63          	beq	a4,a5,80200ef0 <vprintfmt+0x254>
    80200edc:	f5043783          	ld	a5,-176(s0)
    80200ee0:	0007c783          	lbu	a5,0(a5)
    80200ee4:	00078713          	mv	a4,a5
    80200ee8:	07000793          	li	a5,112
    80200eec:	30f71263          	bne	a4,a5,802011f0 <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
    80200ef0:	f5043783          	ld	a5,-176(s0)
    80200ef4:	0007c783          	lbu	a5,0(a5)
    80200ef8:	00078713          	mv	a4,a5
    80200efc:	07000793          	li	a5,112
    80200f00:	00f70663          	beq	a4,a5,80200f0c <vprintfmt+0x270>
    80200f04:	f8144783          	lbu	a5,-127(s0)
    80200f08:	00078663          	beqz	a5,80200f14 <vprintfmt+0x278>
    80200f0c:	00100793          	li	a5,1
    80200f10:	0080006f          	j	80200f18 <vprintfmt+0x27c>
    80200f14:	00000793          	li	a5,0
    80200f18:	faf403a3          	sb	a5,-89(s0)
    80200f1c:	fa744783          	lbu	a5,-89(s0)
    80200f20:	0017f793          	andi	a5,a5,1
    80200f24:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
    80200f28:	fa744783          	lbu	a5,-89(s0)
    80200f2c:	0ff7f793          	zext.b	a5,a5
    80200f30:	00078c63          	beqz	a5,80200f48 <vprintfmt+0x2ac>
    80200f34:	f4843783          	ld	a5,-184(s0)
    80200f38:	00878713          	addi	a4,a5,8
    80200f3c:	f4e43423          	sd	a4,-184(s0)
    80200f40:	0007b783          	ld	a5,0(a5)
    80200f44:	01c0006f          	j	80200f60 <vprintfmt+0x2c4>
    80200f48:	f4843783          	ld	a5,-184(s0)
    80200f4c:	00878713          	addi	a4,a5,8
    80200f50:	f4e43423          	sd	a4,-184(s0)
    80200f54:	0007a783          	lw	a5,0(a5)
    80200f58:	02079793          	slli	a5,a5,0x20
    80200f5c:	0207d793          	srli	a5,a5,0x20
    80200f60:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
    80200f64:	f8c42783          	lw	a5,-116(s0)
    80200f68:	02079463          	bnez	a5,80200f90 <vprintfmt+0x2f4>
    80200f6c:	fe043783          	ld	a5,-32(s0)
    80200f70:	02079063          	bnez	a5,80200f90 <vprintfmt+0x2f4>
    80200f74:	f5043783          	ld	a5,-176(s0)
    80200f78:	0007c783          	lbu	a5,0(a5)
    80200f7c:	00078713          	mv	a4,a5
    80200f80:	07000793          	li	a5,112
    80200f84:	00f70663          	beq	a4,a5,80200f90 <vprintfmt+0x2f4>
                    flags.in_format = false;
    80200f88:	f8040023          	sb	zero,-128(s0)
    80200f8c:	4d00006f          	j	8020145c <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
    80200f90:	f5043783          	ld	a5,-176(s0)
    80200f94:	0007c783          	lbu	a5,0(a5)
    80200f98:	00078713          	mv	a4,a5
    80200f9c:	07000793          	li	a5,112
    80200fa0:	00f70a63          	beq	a4,a5,80200fb4 <vprintfmt+0x318>
    80200fa4:	f8244783          	lbu	a5,-126(s0)
    80200fa8:	00078a63          	beqz	a5,80200fbc <vprintfmt+0x320>
    80200fac:	fe043783          	ld	a5,-32(s0)
    80200fb0:	00078663          	beqz	a5,80200fbc <vprintfmt+0x320>
    80200fb4:	00100793          	li	a5,1
    80200fb8:	0080006f          	j	80200fc0 <vprintfmt+0x324>
    80200fbc:	00000793          	li	a5,0
    80200fc0:	faf40323          	sb	a5,-90(s0)
    80200fc4:	fa644783          	lbu	a5,-90(s0)
    80200fc8:	0017f793          	andi	a5,a5,1
    80200fcc:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
    80200fd0:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
    80200fd4:	f5043783          	ld	a5,-176(s0)
    80200fd8:	0007c783          	lbu	a5,0(a5)
    80200fdc:	00078713          	mv	a4,a5
    80200fe0:	05800793          	li	a5,88
    80200fe4:	00f71863          	bne	a4,a5,80200ff4 <vprintfmt+0x358>
    80200fe8:	00001797          	auipc	a5,0x1
    80200fec:	0d078793          	addi	a5,a5,208 # 802020b8 <upperxdigits.1>
    80200ff0:	00c0006f          	j	80200ffc <vprintfmt+0x360>
    80200ff4:	00001797          	auipc	a5,0x1
    80200ff8:	0dc78793          	addi	a5,a5,220 # 802020d0 <lowerxdigits.0>
    80200ffc:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
    80201000:	fe043783          	ld	a5,-32(s0)
    80201004:	00f7f793          	andi	a5,a5,15
    80201008:	f9843703          	ld	a4,-104(s0)
    8020100c:	00f70733          	add	a4,a4,a5
    80201010:	fdc42783          	lw	a5,-36(s0)
    80201014:	0017869b          	addiw	a3,a5,1
    80201018:	fcd42e23          	sw	a3,-36(s0)
    8020101c:	00074703          	lbu	a4,0(a4)
    80201020:	ff078793          	addi	a5,a5,-16
    80201024:	008787b3          	add	a5,a5,s0
    80201028:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
    8020102c:	fe043783          	ld	a5,-32(s0)
    80201030:	0047d793          	srli	a5,a5,0x4
    80201034:	fef43023          	sd	a5,-32(s0)
                } while (num);
    80201038:	fe043783          	ld	a5,-32(s0)
    8020103c:	fc0792e3          	bnez	a5,80201000 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
    80201040:	f8c42783          	lw	a5,-116(s0)
    80201044:	00078713          	mv	a4,a5
    80201048:	fff00793          	li	a5,-1
    8020104c:	02f71663          	bne	a4,a5,80201078 <vprintfmt+0x3dc>
    80201050:	f8344783          	lbu	a5,-125(s0)
    80201054:	02078263          	beqz	a5,80201078 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
    80201058:	f8842703          	lw	a4,-120(s0)
    8020105c:	fa644783          	lbu	a5,-90(s0)
    80201060:	0007879b          	sext.w	a5,a5
    80201064:	0017979b          	slliw	a5,a5,0x1
    80201068:	0007879b          	sext.w	a5,a5
    8020106c:	40f707bb          	subw	a5,a4,a5
    80201070:	0007879b          	sext.w	a5,a5
    80201074:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    80201078:	f8842703          	lw	a4,-120(s0)
    8020107c:	fa644783          	lbu	a5,-90(s0)
    80201080:	0007879b          	sext.w	a5,a5
    80201084:	0017979b          	slliw	a5,a5,0x1
    80201088:	0007879b          	sext.w	a5,a5
    8020108c:	40f707bb          	subw	a5,a4,a5
    80201090:	0007871b          	sext.w	a4,a5
    80201094:	fdc42783          	lw	a5,-36(s0)
    80201098:	f8f42a23          	sw	a5,-108(s0)
    8020109c:	f8c42783          	lw	a5,-116(s0)
    802010a0:	f8f42823          	sw	a5,-112(s0)
    802010a4:	f9442783          	lw	a5,-108(s0)
    802010a8:	00078593          	mv	a1,a5
    802010ac:	f9042783          	lw	a5,-112(s0)
    802010b0:	00078613          	mv	a2,a5
    802010b4:	0006069b          	sext.w	a3,a2
    802010b8:	0005879b          	sext.w	a5,a1
    802010bc:	00f6d463          	bge	a3,a5,802010c4 <vprintfmt+0x428>
    802010c0:	00058613          	mv	a2,a1
    802010c4:	0006079b          	sext.w	a5,a2
    802010c8:	40f707bb          	subw	a5,a4,a5
    802010cc:	fcf42c23          	sw	a5,-40(s0)
    802010d0:	0280006f          	j	802010f8 <vprintfmt+0x45c>
                    putch(' ');
    802010d4:	f5843783          	ld	a5,-168(s0)
    802010d8:	02000513          	li	a0,32
    802010dc:	000780e7          	jalr	a5
                    ++written;
    802010e0:	fec42783          	lw	a5,-20(s0)
    802010e4:	0017879b          	addiw	a5,a5,1
    802010e8:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    802010ec:	fd842783          	lw	a5,-40(s0)
    802010f0:	fff7879b          	addiw	a5,a5,-1
    802010f4:	fcf42c23          	sw	a5,-40(s0)
    802010f8:	fd842783          	lw	a5,-40(s0)
    802010fc:	0007879b          	sext.w	a5,a5
    80201100:	fcf04ae3          	bgtz	a5,802010d4 <vprintfmt+0x438>
                }

                if (prefix) {
    80201104:	fa644783          	lbu	a5,-90(s0)
    80201108:	0ff7f793          	zext.b	a5,a5
    8020110c:	04078463          	beqz	a5,80201154 <vprintfmt+0x4b8>
                    putch('0');
    80201110:	f5843783          	ld	a5,-168(s0)
    80201114:	03000513          	li	a0,48
    80201118:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
    8020111c:	f5043783          	ld	a5,-176(s0)
    80201120:	0007c783          	lbu	a5,0(a5)
    80201124:	00078713          	mv	a4,a5
    80201128:	05800793          	li	a5,88
    8020112c:	00f71663          	bne	a4,a5,80201138 <vprintfmt+0x49c>
    80201130:	05800793          	li	a5,88
    80201134:	0080006f          	j	8020113c <vprintfmt+0x4a0>
    80201138:	07800793          	li	a5,120
    8020113c:	f5843703          	ld	a4,-168(s0)
    80201140:	00078513          	mv	a0,a5
    80201144:	000700e7          	jalr	a4
                    written += 2;
    80201148:	fec42783          	lw	a5,-20(s0)
    8020114c:	0027879b          	addiw	a5,a5,2
    80201150:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
    80201154:	fdc42783          	lw	a5,-36(s0)
    80201158:	fcf42a23          	sw	a5,-44(s0)
    8020115c:	0280006f          	j	80201184 <vprintfmt+0x4e8>
                    putch('0');
    80201160:	f5843783          	ld	a5,-168(s0)
    80201164:	03000513          	li	a0,48
    80201168:	000780e7          	jalr	a5
                    ++written;
    8020116c:	fec42783          	lw	a5,-20(s0)
    80201170:	0017879b          	addiw	a5,a5,1
    80201174:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
    80201178:	fd442783          	lw	a5,-44(s0)
    8020117c:	0017879b          	addiw	a5,a5,1
    80201180:	fcf42a23          	sw	a5,-44(s0)
    80201184:	f8c42703          	lw	a4,-116(s0)
    80201188:	fd442783          	lw	a5,-44(s0)
    8020118c:	0007879b          	sext.w	a5,a5
    80201190:	fce7c8e3          	blt	a5,a4,80201160 <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
    80201194:	fdc42783          	lw	a5,-36(s0)
    80201198:	fff7879b          	addiw	a5,a5,-1
    8020119c:	fcf42823          	sw	a5,-48(s0)
    802011a0:	03c0006f          	j	802011dc <vprintfmt+0x540>
                    putch(buf[i]);
    802011a4:	fd042783          	lw	a5,-48(s0)
    802011a8:	ff078793          	addi	a5,a5,-16
    802011ac:	008787b3          	add	a5,a5,s0
    802011b0:	f807c783          	lbu	a5,-128(a5)
    802011b4:	0007871b          	sext.w	a4,a5
    802011b8:	f5843783          	ld	a5,-168(s0)
    802011bc:	00070513          	mv	a0,a4
    802011c0:	000780e7          	jalr	a5
                    ++written;
    802011c4:	fec42783          	lw	a5,-20(s0)
    802011c8:	0017879b          	addiw	a5,a5,1
    802011cc:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
    802011d0:	fd042783          	lw	a5,-48(s0)
    802011d4:	fff7879b          	addiw	a5,a5,-1
    802011d8:	fcf42823          	sw	a5,-48(s0)
    802011dc:	fd042783          	lw	a5,-48(s0)
    802011e0:	0007879b          	sext.w	a5,a5
    802011e4:	fc07d0e3          	bgez	a5,802011a4 <vprintfmt+0x508>
                }

                flags.in_format = false;
    802011e8:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    802011ec:	2700006f          	j	8020145c <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    802011f0:	f5043783          	ld	a5,-176(s0)
    802011f4:	0007c783          	lbu	a5,0(a5)
    802011f8:	00078713          	mv	a4,a5
    802011fc:	06400793          	li	a5,100
    80201200:	02f70663          	beq	a4,a5,8020122c <vprintfmt+0x590>
    80201204:	f5043783          	ld	a5,-176(s0)
    80201208:	0007c783          	lbu	a5,0(a5)
    8020120c:	00078713          	mv	a4,a5
    80201210:	06900793          	li	a5,105
    80201214:	00f70c63          	beq	a4,a5,8020122c <vprintfmt+0x590>
    80201218:	f5043783          	ld	a5,-176(s0)
    8020121c:	0007c783          	lbu	a5,0(a5)
    80201220:	00078713          	mv	a4,a5
    80201224:	07500793          	li	a5,117
    80201228:	08f71063          	bne	a4,a5,802012a8 <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
    8020122c:	f8144783          	lbu	a5,-127(s0)
    80201230:	00078c63          	beqz	a5,80201248 <vprintfmt+0x5ac>
    80201234:	f4843783          	ld	a5,-184(s0)
    80201238:	00878713          	addi	a4,a5,8
    8020123c:	f4e43423          	sd	a4,-184(s0)
    80201240:	0007b783          	ld	a5,0(a5)
    80201244:	0140006f          	j	80201258 <vprintfmt+0x5bc>
    80201248:	f4843783          	ld	a5,-184(s0)
    8020124c:	00878713          	addi	a4,a5,8
    80201250:	f4e43423          	sd	a4,-184(s0)
    80201254:	0007a783          	lw	a5,0(a5)
    80201258:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
    8020125c:	fa843583          	ld	a1,-88(s0)
    80201260:	f5043783          	ld	a5,-176(s0)
    80201264:	0007c783          	lbu	a5,0(a5)
    80201268:	0007871b          	sext.w	a4,a5
    8020126c:	07500793          	li	a5,117
    80201270:	40f707b3          	sub	a5,a4,a5
    80201274:	00f037b3          	snez	a5,a5
    80201278:	0ff7f793          	zext.b	a5,a5
    8020127c:	f8040713          	addi	a4,s0,-128
    80201280:	00070693          	mv	a3,a4
    80201284:	00078613          	mv	a2,a5
    80201288:	f5843503          	ld	a0,-168(s0)
    8020128c:	f08ff0ef          	jal	80200994 <print_dec_int>
    80201290:	00050793          	mv	a5,a0
    80201294:	fec42703          	lw	a4,-20(s0)
    80201298:	00f707bb          	addw	a5,a4,a5
    8020129c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802012a0:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    802012a4:	1b80006f          	j	8020145c <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
    802012a8:	f5043783          	ld	a5,-176(s0)
    802012ac:	0007c783          	lbu	a5,0(a5)
    802012b0:	00078713          	mv	a4,a5
    802012b4:	06e00793          	li	a5,110
    802012b8:	04f71c63          	bne	a4,a5,80201310 <vprintfmt+0x674>
                if (flags.longflag) {
    802012bc:	f8144783          	lbu	a5,-127(s0)
    802012c0:	02078463          	beqz	a5,802012e8 <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
    802012c4:	f4843783          	ld	a5,-184(s0)
    802012c8:	00878713          	addi	a4,a5,8
    802012cc:	f4e43423          	sd	a4,-184(s0)
    802012d0:	0007b783          	ld	a5,0(a5)
    802012d4:	faf43823          	sd	a5,-80(s0)
                    *n = written;
    802012d8:	fec42703          	lw	a4,-20(s0)
    802012dc:	fb043783          	ld	a5,-80(s0)
    802012e0:	00e7b023          	sd	a4,0(a5)
    802012e4:	0240006f          	j	80201308 <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
    802012e8:	f4843783          	ld	a5,-184(s0)
    802012ec:	00878713          	addi	a4,a5,8
    802012f0:	f4e43423          	sd	a4,-184(s0)
    802012f4:	0007b783          	ld	a5,0(a5)
    802012f8:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
    802012fc:	fb843783          	ld	a5,-72(s0)
    80201300:	fec42703          	lw	a4,-20(s0)
    80201304:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
    80201308:	f8040023          	sb	zero,-128(s0)
    8020130c:	1500006f          	j	8020145c <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
    80201310:	f5043783          	ld	a5,-176(s0)
    80201314:	0007c783          	lbu	a5,0(a5)
    80201318:	00078713          	mv	a4,a5
    8020131c:	07300793          	li	a5,115
    80201320:	02f71e63          	bne	a4,a5,8020135c <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
    80201324:	f4843783          	ld	a5,-184(s0)
    80201328:	00878713          	addi	a4,a5,8
    8020132c:	f4e43423          	sd	a4,-184(s0)
    80201330:	0007b783          	ld	a5,0(a5)
    80201334:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
    80201338:	fc043583          	ld	a1,-64(s0)
    8020133c:	f5843503          	ld	a0,-168(s0)
    80201340:	dccff0ef          	jal	8020090c <puts_wo_nl>
    80201344:	00050793          	mv	a5,a0
    80201348:	fec42703          	lw	a4,-20(s0)
    8020134c:	00f707bb          	addw	a5,a4,a5
    80201350:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201354:	f8040023          	sb	zero,-128(s0)
    80201358:	1040006f          	j	8020145c <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
    8020135c:	f5043783          	ld	a5,-176(s0)
    80201360:	0007c783          	lbu	a5,0(a5)
    80201364:	00078713          	mv	a4,a5
    80201368:	06300793          	li	a5,99
    8020136c:	02f71e63          	bne	a4,a5,802013a8 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
    80201370:	f4843783          	ld	a5,-184(s0)
    80201374:	00878713          	addi	a4,a5,8
    80201378:	f4e43423          	sd	a4,-184(s0)
    8020137c:	0007a783          	lw	a5,0(a5)
    80201380:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
    80201384:	fcc42703          	lw	a4,-52(s0)
    80201388:	f5843783          	ld	a5,-168(s0)
    8020138c:	00070513          	mv	a0,a4
    80201390:	000780e7          	jalr	a5
                ++written;
    80201394:	fec42783          	lw	a5,-20(s0)
    80201398:	0017879b          	addiw	a5,a5,1
    8020139c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802013a0:	f8040023          	sb	zero,-128(s0)
    802013a4:	0b80006f          	j	8020145c <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
    802013a8:	f5043783          	ld	a5,-176(s0)
    802013ac:	0007c783          	lbu	a5,0(a5)
    802013b0:	00078713          	mv	a4,a5
    802013b4:	02500793          	li	a5,37
    802013b8:	02f71263          	bne	a4,a5,802013dc <vprintfmt+0x740>
                putch('%');
    802013bc:	f5843783          	ld	a5,-168(s0)
    802013c0:	02500513          	li	a0,37
    802013c4:	000780e7          	jalr	a5
                ++written;
    802013c8:	fec42783          	lw	a5,-20(s0)
    802013cc:	0017879b          	addiw	a5,a5,1
    802013d0:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802013d4:	f8040023          	sb	zero,-128(s0)
    802013d8:	0840006f          	j	8020145c <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
    802013dc:	f5043783          	ld	a5,-176(s0)
    802013e0:	0007c783          	lbu	a5,0(a5)
    802013e4:	0007871b          	sext.w	a4,a5
    802013e8:	f5843783          	ld	a5,-168(s0)
    802013ec:	00070513          	mv	a0,a4
    802013f0:	000780e7          	jalr	a5
                ++written;
    802013f4:	fec42783          	lw	a5,-20(s0)
    802013f8:	0017879b          	addiw	a5,a5,1
    802013fc:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201400:	f8040023          	sb	zero,-128(s0)
    80201404:	0580006f          	j	8020145c <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
    80201408:	f5043783          	ld	a5,-176(s0)
    8020140c:	0007c783          	lbu	a5,0(a5)
    80201410:	00078713          	mv	a4,a5
    80201414:	02500793          	li	a5,37
    80201418:	02f71063          	bne	a4,a5,80201438 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
    8020141c:	f8043023          	sd	zero,-128(s0)
    80201420:	f8043423          	sd	zero,-120(s0)
    80201424:	00100793          	li	a5,1
    80201428:	f8f40023          	sb	a5,-128(s0)
    8020142c:	fff00793          	li	a5,-1
    80201430:	f8f42623          	sw	a5,-116(s0)
    80201434:	0280006f          	j	8020145c <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
    80201438:	f5043783          	ld	a5,-176(s0)
    8020143c:	0007c783          	lbu	a5,0(a5)
    80201440:	0007871b          	sext.w	a4,a5
    80201444:	f5843783          	ld	a5,-168(s0)
    80201448:	00070513          	mv	a0,a4
    8020144c:	000780e7          	jalr	a5
            ++written;
    80201450:	fec42783          	lw	a5,-20(s0)
    80201454:	0017879b          	addiw	a5,a5,1
    80201458:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
    8020145c:	f5043783          	ld	a5,-176(s0)
    80201460:	00178793          	addi	a5,a5,1
    80201464:	f4f43823          	sd	a5,-176(s0)
    80201468:	f5043783          	ld	a5,-176(s0)
    8020146c:	0007c783          	lbu	a5,0(a5)
    80201470:	84079ce3          	bnez	a5,80200cc8 <vprintfmt+0x2c>
        }
    }

    return written;
    80201474:	fec42783          	lw	a5,-20(s0)
}
    80201478:	00078513          	mv	a0,a5
    8020147c:	0b813083          	ld	ra,184(sp)
    80201480:	0b013403          	ld	s0,176(sp)
    80201484:	0c010113          	addi	sp,sp,192
    80201488:	00008067          	ret

000000008020148c <printk>:

int printk(const char* s, ...) {
    8020148c:	f9010113          	addi	sp,sp,-112
    80201490:	02113423          	sd	ra,40(sp)
    80201494:	02813023          	sd	s0,32(sp)
    80201498:	03010413          	addi	s0,sp,48
    8020149c:	fca43c23          	sd	a0,-40(s0)
    802014a0:	00b43423          	sd	a1,8(s0)
    802014a4:	00c43823          	sd	a2,16(s0)
    802014a8:	00d43c23          	sd	a3,24(s0)
    802014ac:	02e43023          	sd	a4,32(s0)
    802014b0:	02f43423          	sd	a5,40(s0)
    802014b4:	03043823          	sd	a6,48(s0)
    802014b8:	03143c23          	sd	a7,56(s0)
    int res = 0;
    802014bc:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
    802014c0:	04040793          	addi	a5,s0,64
    802014c4:	fcf43823          	sd	a5,-48(s0)
    802014c8:	fd043783          	ld	a5,-48(s0)
    802014cc:	fc878793          	addi	a5,a5,-56
    802014d0:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
    802014d4:	fe043783          	ld	a5,-32(s0)
    802014d8:	00078613          	mv	a2,a5
    802014dc:	fd843583          	ld	a1,-40(s0)
    802014e0:	fffff517          	auipc	a0,0xfffff
    802014e4:	11850513          	addi	a0,a0,280 # 802005f8 <putc>
    802014e8:	fb4ff0ef          	jal	80200c9c <vprintfmt>
    802014ec:	00050793          	mv	a5,a0
    802014f0:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
    802014f4:	fec42783          	lw	a5,-20(s0)
}
    802014f8:	00078513          	mv	a0,a5
    802014fc:	02813083          	ld	ra,40(sp)
    80201500:	02013403          	ld	s0,32(sp)
    80201504:	07010113          	addi	sp,sp,112
    80201508:	00008067          	ret
