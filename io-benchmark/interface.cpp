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
#include <pthread.h>
#include <stdio.h>

void *io_reader(void *p);
static inline bool _pread(int fd, void *buf, size_t nbyte, off_t offset);
static double gettimeofday_sec();

#define NUM_REQUESTS 100
//#define READ_CHUNK_BASE 1024*1024
#define READ_CHUNK_BASE 1024

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

int read_chunk_size;
double *gps;
struct thread_arg_t {
  int id;
  int fd;
};

int main(int argc, char *argv[])
{
  if (argc != 4) {
    std::cerr << argv[0] << " device-name read-chunk-size(KB) num_threads" << std::endl;
    exit(1);
  }
  char dev[128];
  sprintf(dev, "/dev/%s", argv[1]);
  int fd = open(dev, O_RDONLY | O_DIRECT);
  if (fd < 0) {
    perror("open failed");
    exit(1);
  } 
  read_chunk_size = atoi(argv[2]) * READ_CHUNK_BASE;
  int num_threads = atoi(argv[3]);
  gps = new double[num_threads];
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

  pthread_t tid[num_threads];
  thread_arg_t arg[num_threads];
  for (int i = 0; i < num_threads; ++i) {
    arg[i].id = i;
    arg[i].fd = fd;
    if (pthread_create(&tid[i], NULL, io_reader, (void *) &arg[i]) != 0) {
      perror("pthread_create");
      exit(1);
    }
  }

  void *ret = NULL;
  for (int i = 0; i < num_threads; ++i) {
    if (pthread_join(tid[i], &ret)) {
      perror("pthread_join");
    }
  }

  double gps_total = 0.0;
  for (int i = 0; i < num_threads; ++i) {
    gps_total += gps[i];
  }
  std::cout << gps_total << " Gb/s" << std::endl;

  delete gps;

  return 0;
}

void *io_reader(void *p)
{
  thread_arg_t *arg = (thread_arg_t *) p;
  char *bp; 
  posix_memalign((void **)&bp, 512, read_chunk_size);

  double t1 = gettimeofday_sec();
  for (u64 i = 0; i < NUM_REQUESTS; ++i) {
    if (!_pread(arg->fd, bp, read_chunk_size, 0)) {
      perror("pread");
    }
  }
  double t2 = gettimeofday_sec();
  gps[arg->id] = (double) 8 * read_chunk_size * NUM_REQUESTS / (t2-t1) / (1024*1024*1024);

  return NULL;
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
