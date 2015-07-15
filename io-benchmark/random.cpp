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

static inline bool _pread(int fd, void *buf, size_t nbyte, off_t offset);
static inline off_t random_range(off_t min, off_t max);
void *random_io_reader(void *p);
static double gettimeofday_sec();
unsigned rand256(void);
unsigned long long rand64bits(void);
struct thread_arg_t {
  int id;
  int fd;
};
typedef unsigned int os_random_state_t;

#define NUM_THREAD 1

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

int access_size;
double access_fraction;
int num_requests;
int counter;
int num_threads;
u64 num_blocks;
double *iops;
double *mbps;
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

int main(int argc, char *argv[])
{
  if (argc < 5 || argc > 6) {
    std::cerr << argv[0] << " device-name access-size access-fraction num-requests [num-threads]" << std::endl;
    exit(1);
  }
  char dev[128];
  //sprintf(dev, "/dev/%s", argv[1]);
  sprintf(dev, "%s", argv[1]);
  access_size = atoi(argv[2]);
  access_fraction = atof(argv[3]);
  num_requests = atoi(argv[4]);
  num_threads = NUM_THREAD;
  if (argc == 6) {
    num_threads = atoi(argv[5]);
  }
  iops = new double[num_threads];
  mbps = new double[num_threads];
  int fd;
  struct stat sbuf;
  if (stat(dev, &sbuf) < 0) {
    perror("fstat");
    exit(1);
  }

  int res, t;
  u64 sz;
  if (S_ISBLK(sbuf.st_mode)) {
    fd = open(dev, O_RDONLY | O_DIRECT);
    res = ioctl(fd, BLKSSZGET, &t);
    res = ioctl(fd, BLKGETSIZE64, &sz);
  } else {
    fd = open(dev, O_RDONLY);
    sz = sbuf.st_size;
  }
  if (fd < 0) {
    perror("open");
  } 

#ifdef DEBUG
  printf("sector size: %d\n", t);
  printf("total size :%llu\n", sz);
#endif

  sz *= access_fraction;
  num_blocks = sz / access_size;

  srand((unsigned) time(NULL));
  pthread_t tid[num_threads];
  thread_arg_t arg[num_threads];
  double t1 = gettimeofday_sec();
  for (int i = 0; i < num_threads; ++i) {
    arg[i].id = i;
    arg[i].fd = fd;
    if (pthread_create(&tid[i], NULL, random_io_reader, (void *) &arg[i]) != 0) {
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
  double t2 = gettimeofday_sec();
  double iops_total = 0.0;
  double mbps_total = 0.0;
  for (int i = 0; i < num_threads; ++i) {
    iops_total += iops[i];
    mbps_total += mbps[i];
  }
  //std::cout << access_size << " IOPS: " << iops_total << " MB/s: " << mbps_total/1024/1024 << std::endl;
  //std::cout << access_size << " IOPS: " << num_requests/(t2-t1) << " MB/s: " << (num_requests*access_size)/(t2-t1)/1024/1024 << std::endl;
  std::cout << access_size << " IOPS: " << counter/(t2-t1) << " MB/s: " << (counter*access_size)/(t2-t1)/1024/1024 << std::endl;
  delete iops;
  delete mbps;

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

void *random_io_reader(void *p)
{
  thread_arg_t *arg = (thread_arg_t *) p;
  char *bp; 
  posix_memalign((void **)&bp, 512, access_size);

  int num_reqs_per_thread = num_requests / num_threads;
  double t1 = gettimeofday_sec();
  //for (int i = 0; i < num_reqs_per_thread; ++i) {
  while (true) {
    off_t block_number = random_range(0, num_blocks-1);
    //off_t block_number = rand64bits() % num_blocks;
    //std::cout << arg->id << ": " << block_number << std::endl;
    if (!_pread(arg->fd, bp, access_size, block_number * access_size)) {
      perror("pread");
    }
    pthread_mutex_lock(&mutex);
    ++counter;
    pthread_mutex_unlock(&mutex);
    if (counter >= num_requests) {
      return NULL;
    }
  }
  double t2 = gettimeofday_sec();
  iops[arg->id] = num_reqs_per_thread / (t2-t1);
  mbps[arg->id] = (double) num_reqs_per_thread * access_size / (t2-t1);
  //std::cout << arg->id << ": " << iops[arg->id] << std::endl;
  return NULL;
}

static inline off_t random_range(off_t min, off_t max) 
{
  return min + (rand() * (max - min + 1.0) / ((off_t) RAND_MAX + 1));
}

unsigned rand256(void)
{
  static unsigned const limit = RAND_MAX - RAND_MAX % 256;
  unsigned result = rand();
  while ( result >= limit ) { 
    result = rand();
  }   
  return result % 256;
}

unsigned long long rand64bits(void)
{
  unsigned long long results = 0ULL;
  for ( int count = 8; count > 0; -- count ) { 
    results = 256U * results + rand256();
  }   
  return results;
}
