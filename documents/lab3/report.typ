#import "template.typ": *
#import "extensions.typ": *
#import "@preview/algorithmic:0.1.0"
#import algorithmic: algorithm as _algorithm

#let algorithm(x) = [
  #set table(align: left)
  #_algorithm(x)
]

#show: project.with(
  course: "Operating system",
  title: "Lab 2",
  date: "2024/11/17",
  semester: "Autumn-Fall 2024-2025",
  author: "吴杭",
)

= *Chapter 1*: 实验流程
== setup_vm的实现
// 为了让`mm_init`维护的地址都是虚拟地址，我们需要预先建立一个1GiB的虚拟地址映射，这不是最终的三级页表，这只是临时建立的，为了方便可以只采用一级页表的形式。

首先每个页表自身占据一页的内容，所以我们将页表所在的地址初始化为`0x0`。然后我们在页表里面建立两个映射，第一个是等值映射（把当前的物理地址映射到物理地址），第二个是将虚拟地址的部分映射到物理地址上。

建立等值映射的原因在思考题中会解释。

根据框架注释的提示，代码实现如下：
```c
void setup_vm() {
    // clear up early_pgtbl
    memset(early_pgtbl, 0x0, PGSIZE);

    // record first mapping
    int index = (PHY_START >> 30) & 0x1ff;
    early_pgtbl[index] = ((PHY_START >> 12) << 10) | 0xf;

    // record second mapping
    index = (VM_START >> 30) & 0x1ff;
    early_pgtbl[index] = ((PHY_START >> 12) << 10) | 0xf;
}
```

建立映射后，`mm_init` 所使用的地址变为虚拟地址，需要改变 `mm_init` 中使用的地址范围。

```c
void mm_init(void) {
    kfreerange(_ekernel, (char *)PHY_END + PA2VA_OFFSET);
    printk("...mm_init done!\n");
}
```

== relocate
我们首先需要将`ra`和`sp`的值移动到后续将要读取的虚拟地址上。`PA2VA_OFFSET`是一个比较大的值，所以这里我们的处理如下。
```yasm
# load the value PA2VA_OFFSET in a reg
lui t0, 0xffdf8
slli t0, t0, 16

# set ra = ra + PA2VA_OFFSET
add ra, ra, t0

# set sp = sp + PA2VA_OFFSET
add sp, sp, t0
```

这里要完成对`satp`寄存器的写入操作，根据文档中的介绍，我们需要把`mode`设置为`8`，对应于`Sv39`的模式，然后把`ASID`设置为0，然后在`PPN`中写入页表的地址。
```yasm
    # need a fence to ensure the new translations are in use
    sfence.vma zero, zero

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
```

== setup_vm_final 的实现

为方便后续程序的编写，预先定义 `setup_vm_final` 中将使用的常量。

```c
#define PRIV_V (1 << 0)
#define PRIV_R (1 << 1)
#define PRIV_W (1 << 2)
#define PRIV_X (1 << 3)
#define PRIV_U (1 << 4)
#define PRIV_G (1 << 5)
#define PRIV_A (1 << 6)
#define PRIV_D (1 << 7)

#define MODE_SV39 8
```

`setup_vm_final` 借助以下函数 `create_mapping` 创建映射关系。`create_mapping` 从需要映射的虚拟地址中取出三级页表的索引，根据索引获取对应的页表，最后将物理地址和权限写入页表项中。

```c
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
```

其中，`get_pgtable` 函数用于从上级页表中获取下级页表的地址。如果对应的下级页表不存在，则新建一个页表，将其地址转换为物理地址后写入上级页表中。

```c
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
```

`setup_vm_final` 借助 `create_mapping` 函数将内核的 text 段、rodata 段与 data 段映射到内核的虚拟地址空间中。完成多级页表的建立后，计算得到页表的物理地址，并将其写入 `satp` 中（仍为 Sv39 模式），最后刷新 TLB。

```c
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
```

在 `setup_vm_final` 中，我们需要申请页面以建立多级页表，因此在调用前需要先通过 `mm_init` 将内存管理初始化。

```yasm
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

    # ...
```

= *Chapter 2*: 思考题
== 2.
=== a.
本次实验中建立等值映射的原因在于，在我们设置`satp`之后，我们的PC仍然在物理地址上，程序此时认为自己处于“虚拟地址”上，就会尝试把当前的地址通过页表查找到“物理地址”，如果不建立等值映射，程序就找不到对应的映射后的地址了。

=== b.


= *Chpater 3*: 心得体会
== 遇到的问题


== 心得体会


= *Declaration*

_We hereby declare that all the work done in this lab 2 is of our independent effort._
