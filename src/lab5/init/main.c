#include "defs.h"
#include "printk.h"
extern void schedule();
extern void test();

int start_kernel() {
  printk("2024");
  printk(" ZJU Operating System\n");

  // printk("before writing into the sscratch, the value is 0x%llx\n",
  // csr_read(sscratch)); csr_write(sscratch, 0x1); printk("after writing into
  // the sscratch, the value is 0x%llx\n", csr_read(sscratch));
  schedule();
  test();
  return 0;
}
