#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    // #error Unimplemented
    struct sbiret ret;

    __asm__ volatile (
        // pass eid and fid to a7 and a6
        "mv a7, %[eid]\n"
        "mv a6, %[fid]\n"
        // pass the rest of the arguments to registers
        "mv a5, %[arg5]\n"
        "mv a4, %[arg4]\n"
        "mv a3, %[arg3]\n"
        "mv a2, %[arg2]\n"
        "mv a1, %[arg1]\n"
        "mv a0, %[arg0]\n"
        // call ecall
        "ecall\n"
        // get return values
        "mv %[error], a0\n"
        "mv %[ret_val], a1\n"
        : [error] "=r" (ret.error), [ret_val] "=r" (ret.value)
        : [eid] "r" (eid), [fid] "r" (fid), [arg5] "r" (arg5), [arg4] "r" (arg4), [arg3] "r" (arg3), [arg2] "r" (arg2), [arg1] "r" (arg1), [arg0] "r" (arg0)
        : "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "memory"
    );
    return ret;
}

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    // #error Unimplemented
    // set eid and fid
    uint64_t sbi_debug_console_write_byte_eid = 0x4442434E;
    uint64_t sbi_debug_console_write_byte_fid = 2;
    return sbi_ecall(sbi_debug_console_write_byte_eid, sbi_debug_console_write_byte_fid, byte, 0, 0, 0, 0, 0);

}

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    // #error Unimplemented
    // set eid and fid
    uint64_t sbi_system_reset_eid = 0x53525354;
    uint64_t sbi_system_reset_fid = 0;
    return sbi_ecall(sbi_system_reset_eid, sbi_system_reset_fid, reset_type, reset_reason, 0, 0, 0, 0);
}


struct sbiret sbi_set_timer(uint64_t stime_value) {
    // set eid and fid
    uint64_t sbi_set_timer_eid = 0x54494D45;
    uint64_t sbi_set_timer_fid = 0;
    return sbi_ecall(sbi_set_timer_eid, sbi_set_timer_fid, stime_value, 0, 0, 0, 0, 0);
}