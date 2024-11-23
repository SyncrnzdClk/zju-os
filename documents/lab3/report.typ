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
