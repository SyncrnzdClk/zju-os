#include "defs.h"

#define PRIV_V (1 << 0)
#define PRIV_R (1 << 1)
#define PRIV_W (1 << 2)
#define PRIV_X (1 << 3)
#define PRIV_U (1 << 4)
#define PRIV_G (1 << 5)
#define PRIV_A (1 << 6)
#define PRIV_D (1 << 7)

#define MODE_SV39 8

void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz,
                    uint64_t perm);
                    
void setup_vm();

void setup_vm_final();

uint64_t *get_pgtable(uint64_t *pgtbl, uint64_t vpn);