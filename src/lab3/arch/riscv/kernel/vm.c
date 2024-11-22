#include "defs.h"
#include "string.h"
/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));

void setup_vm() {
    /* 
     * 1. 由于是进行 1GiB 的映射，这里不需要使用多级页表 
     * 2. 将 va 的 64bit 作为如下划分： | high bit | 9 bit | 30 bit |
     *     high bit 可以忽略
     *     中间 9 bit 作为 early_pgtbl 的 index
     *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 + 12，即我们只使用根页表，根页表的每个 entry 都对应 1GiB 的区域
     * 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    **/

    // clear up early_pgtbl
    memset(early_pgtbl, 0x0, PGSIZE);

    // record first mapping
    int index = (PHY_START >> 30) & 0x1ff;
    early_pgtbl[index] = ((PHY_START >> 12) << 10) | 0xf;

    // record second mapping
    index = (VM_START >> 30) & 0x1ff;
    early_pgtbl[index] = ((PHY_START >> 12) << 10) | 0xf;

    // printk("finish set up vm \n");

}