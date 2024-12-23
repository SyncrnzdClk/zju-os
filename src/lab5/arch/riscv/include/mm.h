#ifndef __MM_H__
#define __MM_H__

#include "stdint.h"

#define VA2PA(x) ((x - (uint64_t)PA2VA_OFFSET))
#define PA2VA(x) ((x + (uint64_t)PA2VA_OFFSET))
#define PFN2PHYS(x) (((uint64_t)(x) << 12) + PHY_START)
#define PHYS2PFN(x) ((((uint64_t)(x) - PHY_START) >> 12))

struct run {
    struct run *next;
};

void mm_init();

void *kalloc();
void kfree(void *);

struct buddy {
  uint64_t size;
  uint64_t *bitmap;
  uint64_t *ref_cnt; 
};

uint64_t get_page(void *); // increase ref_cnt
void put_page(void *); // decrease ref_cnt
uint64_t get_page_refcnt(void *); // get ref_cnt


void buddy_init();
uint64_t buddy_alloc(uint64_t);
void buddy_free(uint64_t);

void *alloc_pages(uint64_t);
void *alloc_page();
void free_pages(void *);

#endif