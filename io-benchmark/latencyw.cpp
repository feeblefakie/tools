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

static inline bool _pread(int fd, void *buf, size_t nbyte, off_t offset);
static inline bool _pwrite(int fd, const void *buf, size_t nbyte, off_t offset);
static double gettimeofday_sec();

#define FS_USED 190*1024*1024

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
  if (argc != 4) {
    std::cerr << argv[0] << " device-name location(sectors) length" << std::endl;
    exit(1);
  }
  char dev[128];
  sprintf(dev, "/dev/%s", argv[1]);
  int num_of_sectors = atoi(argv[2]);
  int length = atoi(argv[3]);
  int fd = open(dev, O_RDWR | O_DIRECT | O_SYNC);
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

  if ((u64) t*num_of_sectors > sz ||
      num_of_sectors < 0) {
    std::cerr << "invalid seek distance" << std::endl;
    exit(1);
  }

  ///* TEST
  char *rp; 
  posix_memalign((void **)&rp, 512, t);
  if (!_pread(fd, rp, t, 0)) {
    perror("2 pread");
  }
  //*/

  char *bp; 
  posix_memalign((void **)&bp, 512, length);
  off_t offset = (off_t) t * num_of_sectors;
  /*
  if (offset < FS_USED) {
    exit(1);
  }
  */
  double t1 = gettimeofday_sec();
  if (!_pwrite(fd, bp, length, offset)) {
    perror("3 pwrite");
    std::cerr << "offset: " << offset << ", length: " << length << std::endl;
    exit(1);
  }
  double t2 = gettimeofday_sec();
  std::cout << "write latency for " << length << " bytes at " << num_of_sectors << " : " << t2 - t1 << std::endl;

  return 0;
}

static inline
bool _pwrite(int fd, const void *buf, size_t nbyte, off_t offset)
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

static inline
bool _pread(int fd, void *buf, size_t nbyte, off_t offset)
{
  char *p = reinterpret_cast<char *>(buf);
  const char * const end_p = p + nbyte;

  while (p < end_p) {
    int num_bytes;
    SAFE_SYSCALL(num_bytes, pread(fd, p, end_p - p, offset));
    if (num_bytes == 0) {
      break;
    }
    if (num_bytes < 0) {
      perror("read failed");
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
