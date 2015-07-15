#include <iostream>
#include <linux/unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <time.h>
#include <sys/time.h>
#include <sys/types.h>
#include <stdio.h>
#include <string.h>

static inline bool _pwrite(int fd, const void *buf, size_t nbyte, off_t offset);
static double gettimeofday_sec();

#define WRITE_CHUNK_SIZE (1024*1024*100)
//#define WRITE_CHUNK_SIZE (65536)
#define FS_USED 1024*1024*188
#define BUNCH_NUM (1024*1024*100/WRITE_CHUNK_SIZE)

#if defined(_IO) && !defined(BLKSSZGET)
#define BLKSSZGET  _IO(0x12,104)
#endif

#ifndef u64
typedef unsigned long long u64;
#endif
#if defined(_IO) && !defined(BLKGETSIZE64)
#define BLKGETSIZE64 _IOR(0x12,114,u64)
#endif

#define SAFE_SYSCALL3(result, expr, check) \
  do { \
    (result) = (expr); \
    if ((check) && errno == EINTR) { \
      errno = 0; \
    } else { \
      break; \
    } \
  } while (1)

#define SAFE_SYSCALL(result, expr) \
  SAFE_SYSCALL3(result, expr, (result < 0))

int main(int argc, char *argv[])
{
  if (argc != 2) {
    std::cerr << argv[0] << " device-name" << std::endl;
    exit(1);
  }
  char dev[128];
  sprintf(dev, "/dev/%s", argv[1]);
  int fd = open(dev, O_RDWR | O_DIRECT);
  if (fd < 0) {
    perror("open failed");
    exit(1);
  } 
  struct stat sbuf;
  if (fstat(fd, &sbuf) < 0) {
    perror("fstat failed");
    exit(1);
  }

  int res, t;
  res = ioctl(fd, BLKSSZGET, &t);
  u64 sz;
  res = ioctl(fd, BLKGETSIZE64, &sz);
#ifdef DEBUG
  printf("sector size: %d\n", t);
  printf("total size: %llu\n", sz);
#endif

  char *bp; 
  posix_memalign((void **)&bp, 512, WRITE_CHUNK_SIZE);
  memset(bp, 0, WRITE_CHUNK_SIZE);

  u64 ionum = sz / (WRITE_CHUNK_SIZE);
  double t1 = gettimeofday_sec();
  double t2;
  // assume that first 188MB is used for FS
  u64 i = (int) (FS_USED) / (WRITE_CHUNK_SIZE);
  if ((FS_USED) % (WRITE_CHUNK_SIZE) != 0) {
    i++;
  }
  for (; i < ionum; ++i) {
    _pwrite(fd, bp, WRITE_CHUNK_SIZE, i*WRITE_CHUNK_SIZE);
    if ((i+1) % BUNCH_NUM == 0) {
      t2 = gettimeofday_sec();
      std::cout << "i = " << i << " : 100M for " << t2 - t1 << " (s) " << 100/(t2-t1) << " (MB/s)"  <<  std::endl;
      t1 = t2;
    }
  }

  return 0;
}

static inline bool _pwrite(int fd, const void *buf, size_t nbyte, off_t offset)
{
  //printf("fd=%d, buf=%x, nbyte=%d, offset=%d\n", fd, buf, nbyte, offset);
  const char *p = reinterpret_cast<const char *>(buf);
  const char * const end_p = p + nbyte;

  while (p < end_p) {
    int num_bytes;
    SAFE_SYSCALL(num_bytes, pwrite(fd, p, end_p - p, offset));
    if (num_bytes < 0) {
      perror("write failed");
      break;
    }
    p += num_bytes;
    offset += num_bytes;
  }

  if (p != end_p) {
    return false;
  }
  return true;
}

static double 
gettimeofday_sec()
{
  struct timeval tv; 
  gettimeofday(&tv, NULL);
  return tv.tv_sec + (double)tv.tv_usec*1e-6;
}
