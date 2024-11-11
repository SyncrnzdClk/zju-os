#include "defs.h"
#include "printk.h"
void test() {
  int i = 0;
  while (1) {
    if ((++i) % 100000000 == 0) {
      // printk("in test, the value of sstatus is %llx \n", csr_read(sstatus));
      // printk("kernel is running!\n");
      i = 0;
    }
  }
}
