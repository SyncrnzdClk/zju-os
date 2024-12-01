#include "defs.h"
#include "mm.h"
#include "printk.h"
#include "string.h"
#include "vm.h"

/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));

void setup_vm() {
  /*
   * 1. 由于是进行 1GiB 的映射，这里不需要使用多级页表
   * 2. 将 va 的 64bit 作为如下划分： | high bit | 9 bit | 30 bit |
   *     high bit 可以忽略
   *     中间 9 bit 作为 early_pgtbl 的 index
   *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 +
   *12，即我们只使用根页表，根页表的每个 entry 都对应 1GiB 的区域
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
}





/* swapper_pg_dir: kernel pagetable 根目录，在 setup_vm_final 进行映射 */
uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

extern uint64_t _stext, _srodata, _sdata;

void setup_vm_final() {
  memset(swapper_pg_dir, 0x0, PGSIZE);

  // No OpenSBI mapping required

  // mapping kernel text X|-|R|V
  uint64_t size_text = ((uint64_t)&_srodata - (uint64_t)&_stext) >> 12;
  create_mapping(swapper_pg_dir, (uint64_t)&_stext,
                 (uint64_t)&_stext - PA2VA_OFFSET, size_text,
                 PRIV_X | PRIV_R | PRIV_V);

  // mapping kernel rodata -|-|R|V
  uint64_t size_rodata = ((uint64_t)&_sdata - (uint64_t)&_srodata) >> 12;
  create_mapping(swapper_pg_dir, (uint64_t)&_srodata,
                 (uint64_t)&_srodata - PA2VA_OFFSET, size_rodata,
                 PRIV_R | PRIV_V);

  // mapping other memory -|W|R|V
  create_mapping(swapper_pg_dir, (uint64_t)&_sdata,
                 (uint64_t)&_sdata - PA2VA_OFFSET,
                 32768 - size_text - size_rodata, PRIV_W | PRIV_R | PRIV_V);

  // set satp with swapper_pg_dir

  // physical address of swapper_pg
  uint64_t swapper_pg_dir_pa = (uint64_t)swapper_pg_dir - PA2VA_OFFSET;
  uint64_t satp =
      ((uint64_t)MODE_SV39 << 60) | ((uint64_t)swapper_pg_dir_pa >> 12);
  asm volatile("csrw satp, %0" ::"r"(satp));

  // flush TLB
  asm volatile("sfence.vma zero, zero");
  return;
}

uint64_t *get_pgtable(uint64_t *pgtbl, uint64_t vpn) {
  // check if page already exists
  if (pgtbl[vpn] & PRIV_V) { // exists
    return (uint64_t *)((pgtbl[vpn] & 0x3ffffffffffc00) << 2);
  } else { // does not exist
    uint64_t *new_pgtbl = kalloc();
    memset(new_pgtbl, 0x0, PGSIZE);
    uint64_t new_pgtbl_pa = (uint64_t)new_pgtbl - PA2VA_OFFSET;
    pgtbl[vpn] = ((uint64_t)new_pgtbl_pa >> 2) | PRIV_V;
    return new_pgtbl;
  }
}

/* 创建多级页表映射关系 */
/* 不要修改该接口的参数和返回值 */
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz,
                    uint64_t perm) {
  /*
   * pgtbl 为根页表的基地址
   * va, pa 为需要映射的虚拟地址、物理地址
   * sz 为映射的大小，单位为字节
   * perm 为映射的权限（即页表项的低 8 位）
   *
   * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
   * 可以使用 V bit 来判断页表项是否存在
   **/
  for (int i = 0; i < sz; ++i, va += 0x1000, pa += 0x1000) {
    // virtual page number
    uint64_t vpn0 = (va >> 12) & 0x1ff;
    uint64_t vpn1 = (va >> 21) & 0x1ff;
    uint64_t vpn2 = (va >> 30) & 0x1ff;

    uint64_t *pgtbl1 = get_pgtable(pgtbl, vpn2);
    uint64_t *pgtbl0 = get_pgtable(pgtbl1, vpn1);

    // check if page already exists
    if (!(pgtbl0[vpn0] & PRIV_V)) {
      // write pa and perm
      pgtbl0[vpn0] = perm | ((pa >> 2) & 0x3ffffffffffc00);
    }
  }
}
