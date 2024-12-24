#include "fs.h"
#include "fat32.h"
#include "mm.h"
#include "printk.h"
#include "string.h"
#include "vfs.h"

struct files_struct *file_init() {
  // todo: alloc pages for files_struct, and initialize stdin, stdout, stderr
  // alloc pages for file struct
  struct files_struct *ret = NULL;
  // calculate the size of files_struct and the pages number it needs
  uint64_t files_struct_size = sizeof(struct files_struct);
  uint64_t pages = (files_struct_size + PGSIZE - 1) / PGSIZE;
  struct files_struct *files_struct_space =
      (struct files_struct *)alloc_pages(pages);
  if (files_struct_space == NULL) {
    printk(RED "Failed to alloc pages for files_struct\n" CLEAR);
    return NULL;
  }
  memset(files_struct_space, 0, files_struct_size);
  // initialize stdin, stdout, stderr
  // stdin
  files_struct_space->fd_array[0].opened = 1;
  files_struct_space->fd_array[0].perms = FILE_READABLE;
  files_struct_space->fd_array[0].cfo = 0;
  files_struct_space->fd_array[0].lseek = NULL;
  files_struct_space->fd_array[0].write = NULL;
  files_struct_space->fd_array[0].read = stdin_read;
  // stdout
  files_struct_space->fd_array[1].opened = 1;
  files_struct_space->fd_array[1].perms = FILE_WRITABLE;
  files_struct_space->fd_array[1].cfo = 0;
  files_struct_space->fd_array[1].lseek = NULL;
  files_struct_space->fd_array[1].write = stdout_write;
  files_struct_space->fd_array[1].read = NULL;
  // stderr
  files_struct_space->fd_array[2].opened = 1;
  files_struct_space->fd_array[2].perms = FILE_WRITABLE;
  files_struct_space->fd_array[2].cfo = 0;
  files_struct_space->fd_array[2].lseek = NULL;
  files_struct_space->fd_array[2].write = stderr_write;
  files_struct_space->fd_array[2].read = NULL;
  ret = files_struct_space;
  return ret;
}

uint32_t get_fs_type(const char *filename) {
  uint32_t ret;
  if (memcmp(filename, "/fat32/", 7) == 0) {
    ret = FS_TYPE_FAT32;
  } else if (memcmp(filename, "/ext2/", 6) == 0) {
    ret = FS_TYPE_EXT2;
  } else {
    ret = -1;
  }
  return ret;
}

int32_t file_open(struct file *file, const char *path, int flags) {
  file->opened = 1;
  file->perms = flags;
  file->cfo = 0;
  file->fs_type = get_fs_type(path);
  memcpy(file->path, path, strlen(path) + 1);

  if (file->fs_type == FS_TYPE_FAT32) {
    file->lseek = fat32_lseek;
    file->write = fat32_write;
    file->read = fat32_read;
    file->fat32_file = fat32_open_file(path);
    // todo: check if fat32_file is valid (i.e. successfully opened) and return
  } else if (file->fs_type == FS_TYPE_EXT2) {
    printk(RED "Unsupport ext2\n" CLEAR);
    return -1;
  } else {
    printk(RED "Unknown fs type: %s\n" CLEAR, path);
    return -1;
  }
}
