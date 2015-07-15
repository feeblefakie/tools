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
static double gettimeofday_sec();

//#define READ_CHUNK_SIZE 1024*1024*100
//#define BUNCH_NUM 1
#define READ_CHUNK_SIZE 10485760
//#define READ_CHUNK_SIZE 65536
#define BUNCH_NUM (1024*1024*100/READ_CHUNK_SIZE)

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
  int fd = open(dev, O_RDONLY | O_DIRECT);
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
  posix_memalign((void **)&bp, 512, READ_CHUNK_SIZE);

  u64 ionum = sz / READ_CHUNK_SIZE;
  double t1 = gettimeofday_sec();
  double t2;
  // short 
  /*
  for (u64 i = 0; i < ionum, i < 200; ++i) {
    _pread(fd, bp, READ_CHUNK_SIZE, i*READ_CHUNK_SIZE);
  }
  */
  // all
  for (u64 i = 0; i < ionum; ++i) {
    _pread(fd, bp, READ_CHUNK_SIZE, i*READ_CHUNK_SIZE);
    if ((i+1) % BUNCH_NUM == 0) {
      t2 = gettimeofday_sec();
      std::cout << "i = " << i << " : 100M for " << t2 - t1 << " (s) " << 100/(t2-t1) << " (MB/s)" <<  std::endl;
      t1 = t2;
    }
  }
  t2 = gettimeofday_sec();
  std::cout << READ_CHUNK_SIZE*200/(t2-t1)/1024/1024 << " MB/s" << std::endl;

  return 0;
}

static inline
bool _pread(int fd, void *buf, size_t nbyte, off_t offset)
{
  char *p = reinterpret_cast<char *>(buf);
  const char * const end_p = p + nbyte;

  while (p < end_p) {
    int num_bytes;
    SAFE_SYSCALL(num_bytes, pread(fd, p, end_p - p, offset));
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
