#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
    char *s = (char *)dest;
    for (uint64_t i = 0; i < n; ++i) {
        s[i] = c;
    }
    return dest;
}

void *memcpy(void *dst, void *src, uint64_t n) {
    char *chr_dst = (char *)dst;
    char *chr_src = (char *)src;
    for (uint64_t i = 0; i < n; ++i) 
        chr_dst[i] = chr_src[i];

    return dst;
}