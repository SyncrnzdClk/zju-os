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
    for (uint64_t i = 0; i < n; ++i) {
        chr_dst[i] = chr_src[i];
    }
    return dst;
}

uint64_t memcmp(void *s1, void *s2, uint64_t n) {
    char *c1 = (char *)s1;
    char *c2 = (char *)s2;
    for (uint64_t i = 0; i < n; ++i) {
        if (c1[i] != c2[i]) {
            return (c1[i] - c2[i]);
        }
    }
    return 0;
}

uint64_t strlen(const char *s) {
    uint64_t len = 0;
    while (s[len] != '\0') {
        len++;
    }
    return len;
}