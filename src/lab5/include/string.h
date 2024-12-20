#ifndef __STRING_H__
#define __STRING_H__

#include "stdint.h"

void *memset(void *, int, uint64_t);

// personally added
void *memcpy(void *dst, void *src, uint64_t n);

#endif
