# 浙江大学实验报告

课程名称：操作系统
实验项目名称：RV64 缺页异常处理与 fork 机制
实验平台：Ubuntu 24.04.1（在 Windows 11 下使用 Oracle VirtualBox 作为虚拟环境）
学生姓名：李克成&emsp;&emsp;学号：3220103579
电子邮件地址：lkc314@qq.com
实验日期：2024 年 12 月 22 日

## 一、实验内容

### 1.1 准备工作

根据实验指导，同步 `user/main.c` 并在 `user/Makefile` 中添加 `TEST` 相关逻辑。

### 1.2 缺页异常处理

#### 1.2.1 实现虚拟内存管理功能

根据实验指导，在 `defs.h` 中添加 VMA Flags 的定义。

```c
// defs.h
#define VM_ANON 0x1
#define VM_READ 0x2
#define VM_WRITE 0x4
#define VM_EXEC 0x8
```

在 `proc.h` 中增加 `mm_struct` 与 `vm_area_struct` 的定义并声明 `find_vma` 与 `do_mmap`。

```c
// proc.h
struct vm_area_struct {
  struct mm_struct *vm_mm;
  uint64_t vm_start;
  uint64_t vm_end;
  struct vm_area_struct *vm_next, *vm_prev;
  uint64_t vm_flags;
  uint64_t vm_pgoff;
  uint64_t vm_filesz;
};

struct mm_struct {
  struct vm_area_struct *mmap;
};

struct task_struct {
  uint64_t state;
  uint64_t counter;
  uint64_t priority;
  uint64_t pid;

  struct thread_struct thread;
  uint64_t *pgd; // 用户态页表
  struct mm_struct mm;
};

// ...

/**
 * @param mm   current thread's mm_struct
 * @param addr the va to look up
 *
 * @return the VMA if found or NULL if not found
 */
struct vm_area_struct *find_vma(struct mm_struct *mm, uint64_t addr);

/**
 * @param mm        current thread's mm_struct
 * @param addr      the va to map
 * @param len       memory size to map
 * @param vm_pgoff  phdr->p_offset
 * @param vm_filesz phdr->p_filesz
 * @param flags     flags for the new VMA
 *
 * @return start va
 */
uint64_t do_mmap(struct mm_struct *mm, uint64_t addr, uint64_t len,
                 uint64_t vm_pgoff, uint64_t vm_filesz, uint64_t flags);

```

对于 `find_vma` 函数，遍历 VMA 链表，如果能找到包含了 `addr` 的表项就返回该表项。

```c
struct vm_area_struct *find_vma(struct mm_struct *mm, uint64_t addr) {
  for (struct vm_area_struct *vma = mm->mmap; vma != NULL; vma = vma->vm_next) {
    if (vma->vm_start <= addr && addr < vma->vm_end) {
      return vma;
    }
  }
  return NULL;
}
```

对于 `do_mmap` 函数，建立新节点并写入相关数据，将新节点加入至链表首。如果原先的链表首非空，则更新其 `vm_prev` 成员。

```c
uint64_t do_mmap(struct mm_struct *mm, uint64_t addr, uint64_t len,
                 uint64_t vm_pgoff, uint64_t vm_filesz, uint64_t flags) {
  Log("mmap [0x%lx, 0x%lx), pgoff = 0x%lx, filesz = 0x%lx, flags = 0x%lx", addr,
      addr + len, vm_pgoff, vm_filesz, flags);
  struct vm_area_struct *vma = mm->mmap;
  struct vm_area_struct *node = (struct vm_area_struct *)kalloc();
  *node = (struct vm_area_struct){
      .vm_mm = mm,
      .vm_start = addr,
      .vm_end = addr + len,
      .vm_next = vma,
      .vm_prev = NULL,
      .vm_flags = flags,
      .vm_pgoff = vm_pgoff,
      .vm_filesz = vm_filesz,
  };
  if (vma != NULL) {
    vma->vm_prev = node;
  }
  mm->mmap = node;
  return addr;
}
```

#### 1.2.2 修改 `task_init`

注释先前实验对用户栈与 ELF 文件 loadable segment 使用空间的申请与映射代码。

对于 ELF 文件加载，根据读取到的权限信息调用 `do_mmap`。

```c
// load_elf()
// allocate pages for the uapp
// char *uapp_space = alloc_pages(pages);
// memcpy(uapp_space + shift, _sramdisk + program_header->p_offset,
//        program_header->p_memsz);
uint64_t priv = program_header->p_flags;
// uint64_t priv_r = priv & PF_R ? PRIV_R : 0;
// uint64_t priv_w = priv & PF_W ? PRIV_W : 0;
// uint64_t priv_x = priv & PF_X ? PRIV_X : 0;
// create the address mapping for uapp
// create_mapping(new_task->pgd, PGROUNDDOWN(program_header->p_vaddr),
//                VA2PA((uint64_t)uapp_space), pages << 12,
//                PRIV_U | priv_w | priv_x | priv_r | PRIV_V);
uint64_t priv_r = priv & PF_R ? VM_READ : 0;
uint64_t priv_w = priv & PF_W ? VM_WRITE : 0;
uint64_t priv_x = priv & PF_X ? VM_EXEC : 0;
do_mmap(&new_task->mm, program_header->p_vaddr, program_header->p_memsz,
        program_header->p_offset, program_header->p_filesz,
        priv_r | priv_w | priv_x);
```

对于用户栈申请，将其权限设置为可读、可写且匿名。

```c
// task_init()

// allocate one page for the stack of user mode
// char *stack_umode = alloc_page();

// add the mapping into the pgd
// create_mapping(new_task->pgd, PGROUNDDOWN(USER_END - 1),
//                VA2PA((uint64_t)stack_umode), PGSIZE,
//                PRIV_U | PRIV_W | PRIV_R | PRIV_V);
do_mmap(&new_task->mm, USER_END - PGSIZE, PGSIZE, 0, 0,
        VM_READ | VM_WRITE | VM_ANON);
```

#### 1.2.3 实现 page fault handler

在 `trap_handler` 中增加对 `do_page_fault` 的调用：

```c
// trap_handler()
if (timer_interrupt) {
    // ...
} else {
    if (scause == 8) {
        // ...
    } else if (scause == INST_PAGE_FAULT || scause == LOAD_PAGE_FAULT ||
               scause == STORE_PAGE_FAULT) {
      do_page_fault(regs);
    } else {
      Err("unhandled trap: scause = %lu, sepc = 0x%lx, stval = 0x%lx", scause,
          sepc, csr_read(stval));
    }
}
```

在 `do_page_fault` 中：
* 首先根据访问异常的地址 `bad_addr` 获取对应的 VMA；
* 分配新的页 `page` 并建立从 `bad_addr` 所在页到 `page` 的映射
* 当这一页为匿名页时，加载程序段
  * 如果这一段使用了介于 `[filesz,memsz)` 之间的地址，则将这部分地址清空

代码实现：（不含 COW 相关逻辑）

```c
void do_page_fault(struct pt_regs *regs) {
  // get bad address
  uint64_t bad_addr = csr_read(stval);
  Log("page fault at 0x%lx, sepc = 0x%lx", bad_addr, regs->sepc);
  struct vm_area_struct *vma = find_vma(&current->mm, bad_addr);
  if (vma == NULL) {
    // VM area not found (should not reach here)
    Err("page fault at 0x%lx, but cannot find the vma, current task's pid is "
        "%lx",
        bad_addr, current->pid);
    return;
  }
  uint64_t scause = csr_read(scause);
  if (scause == INST_PAGE_FAULT && (vma->vm_flags & VM_EXEC) == 0) {
    // instruction page fault but the vma is not executable
    Err("instruction page fault at 0x%lx, but the vma is not executable",
        bad_addr);
    return;
  } else if (scause == LOAD_PAGE_FAULT && (vma->vm_flags & VM_READ) == 0) {
    // load page fault but the vma is not readable
    Err("load page fault at 0x%lx, but the vma is not readable", bad_addr);
    return;
  } else if (scause == STORE_PAGE_FAULT && (vma->vm_flags & VM_WRITE) == 0) {
    // store page fault but the vma is not writable
    Err("store page fault at 0x%lx, but the vma is not writable", bad_addr);
    return;
  }

  // read priviledges
  uint64_t priv_r = (vma->vm_flags & VM_READ) ? PRIV_R : 0;
  uint64_t priv_w = (vma->vm_flags & VM_WRITE) ? PRIV_W : 0;
  uint64_t priv_x = (vma->vm_flags & VM_EXEC) ? PRIV_X : 0;

  uint64_t *page = alloc_page();

  create_mapping(current->pgd, PGROUNDDOWN(bad_addr), VA2PA((uint64_t)page),
                 PGSIZE, PRIV_U | priv_r | priv_w | priv_x | PRIV_V);
  if ((vma->vm_flags & VM_ANON) == 0) {
    // bad_addr - vma->vm_start is the offset
    // copy the content of the file to the page
    uint64_t offset = bad_addr - vma->vm_start;
    uint64_t program_page =
        PGROUNDDOWN((uint64_t)_sramdisk + vma->vm_pgoff + offset);
    uint64_t page_end = PGROUNDDOWN(bad_addr) + PGSIZE;
    // Log("vm_start = 0x%lx, vm_pgoff = 0x%lx, offset = 0x%lx, filesz = 0x%lx",
    //     vma->vm_start, vma->vm_pgoff, offset, vma->vm_filesz);
    memcpy(page, (void *)program_page, PGSIZE);
    if (vma->vm_start + vma->vm_filesz < page_end) {
      uint64_t rest = min(PGSIZE, page_end - vma->vm_start - vma->vm_filesz);
      // Log("zero rest part: 0x%lx", rest);
      memset(page + PGSIZE - rest, 0, rest);
    }
  }
}
```

### 1.3 实现 fork 系统调用

<!-- TODO -->

## 二、思考题

已实现 COW 功能。

1. 画图分析 `make run TEST=FORK3` 的进程 fork 过程，并呈现出各个进程的 `global_variable` 应该从几开始输出，再与你的输出进行对比验证。

## 三、讨论心得