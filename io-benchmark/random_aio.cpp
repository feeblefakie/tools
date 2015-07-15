#include <libaio.h>
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
#include <assert.h>
#include <stdio.h>

#if defined(_IO) && !defined(BLKSSZGET)
#define BLKSSZGET  _IO(0x12,104)
#endif
  
#ifndef u64
typedef unsigned long long u64;
#endif
#if defined(_IO) && !defined(BLKGETSIZE64)
#define BLKGETSIZE64 _IOR(0x12,114,u64)
#endif 
  
#if defined(_IO) && !defined(BLKGETSIZE)
#define BLKGETSIZE _IO(0x12,96) /* return device size /512 (long *arg) */
#endif

#define REQUEST_CHUNK 100000

static double gettimeofday_sec();
static void read_done(io_context_t ctx, struct iocb *iocb, long res, long res2);
static inline off_t random_range(off_t min, off_t max);
void random_io(int fd, off_t num_blocks, int access_size, int num_requests);
void *random_io_reader(void *p);
static double gettimeofday_sec();
unsigned rand256(void);
unsigned long long rand64bits(void);
struct thread_arg_t {
  int id;
  int fd;
  off_t num_blocks;
  int access_size;
  int num_requests;
};
double *iops;
double *mbps;

int main(int argc, char **argv)
{
  if (argc < 5 || argc > 6) {
    std::cerr << argv[0] << " device-name access-size access-fraction num-requests [num-threads]" << std::endl;
    exit(1);
  }
  char dev[128];
  sprintf(dev, "%s", argv[1]);
  int access_size = atoi(argv[2]);
  double access_fraction = atof(argv[3]);
  int num_requests = atoi(argv[4]);
  int num_threads = 1;
  if (argc == 6) {
    num_threads = atoi(argv[5]);
  }
  iops = new double[num_threads];
  mbps = new double[num_threads];

  int fd = open(dev, O_RDONLY | O_DIRECT);
  if (fd < 0) {
    perror("open");
  }
  struct stat sbuf;
  if (fstat(fd, &sbuf) < 0) {
    perror("fstat");
    exit(1);
  }

  int res, t;
  res = ioctl(fd, BLKSSZGET, &t);
  off_t sz;
  res = ioctl(fd, BLKGETSIZE64, &sz);
#ifdef DEBUG
  printf("sector size: %d\n", t);
  printf("total size :%llu\n", sz);
#endif

  sz = (off_t) (sz * access_fraction);
  off_t num_blocks = sz / access_size;

  srand((unsigned) time(NULL));

  pthread_t tid[num_threads];
  thread_arg_t arg[num_threads];
  int num_requests_per_thread = num_requests / num_threads;
  for (int i = 0; i < num_threads; ++i) {
    arg[i].id = i;
    arg[i].fd = fd;
    arg[i].num_blocks = num_blocks;
    arg[i].access_size = access_size;
    arg[i].num_requests = num_requests_per_thread;
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
  double iops_total = 0.0;
  double mbps_total = 0.0;
  for (int i = 0; i < num_threads; ++i) {
    iops_total += iops[i];
    mbps_total += mbps[i];
  }
  std::cout << access_size << " IOPS: " << iops_total << " MB/s: " << mbps_total/1024/1024 << std::endl;
  delete iops;
  delete mbps;

  return 0;
}

void *random_io_reader(void *p)
{
  thread_arg_t *arg = (thread_arg_t *) p;
  double t1 = gettimeofday_sec();
  random_io(arg->fd, arg->num_blocks, arg->access_size, arg->num_requests);
  double t2 = gettimeofday_sec();
  iops[arg->id] = arg->num_requests / (t2-t1);
  mbps[arg->id] = (double) arg->num_requests * arg->access_size / (t2-t1);
  return NULL;
}

static void
read_done(io_context_t ctx, struct iocb *iocb, long res, long res2)
{
  //std::cout << "hello" << std::endl;
  //printf("%ld read\n", res);
  return;
}

void random_io(int fd, off_t num_blocks, int access_size, int num_requests)
{
  for (int k = 0; k < num_requests; k += REQUEST_CHUNK) {
    int n_requests = REQUEST_CHUNK;
    if (num_requests - k < REQUEST_CHUNK) {
      n_requests = num_requests - k;
    }
    // (1) io_context_tの初期化
    io_context_t ctx;
    memset(&ctx, 0, sizeof(io_context_t));
    int r = io_setup(n_requests, &ctx);
    assert(r == 0);

    // (2) iocbs(I/O要求)の構築
    struct iocb **iocbs = new struct iocb*[n_requests];
    char **bufs = new char*[n_requests];
    for (int i = 0; i < n_requests; i++) {
      iocbs[i] = new struct iocb();
      posix_memalign((void **)&bufs[i], 512, access_size);

      off_t block_number = random_range(0, num_blocks-1);
      //off_t block_number = rand64bits() % num_blocks;
      io_prep_pread(iocbs[i], fd, bufs[i], access_size, block_number * access_size);
      io_set_callback(iocbs[i], read_done);
    }

    // (3) I/O要求を投げる
    r = io_submit(ctx, n_requests, iocbs);
    assert(r == n_requests);

    // (4) 完了したI/O要求を待ち、終わったものについてはcallbackを呼び出す
    int cnt = 0;
    while (true) {
      struct io_event events[32];
      int n = io_getevents(ctx, 1, 32, events, NULL);
      if (n > 0)
        cnt += n;

      for (int i = 0; i < n; i++) {
        struct io_event *ev = events + i;
        io_callback_t callback = (io_callback_t)ev->data;
        struct iocb *iocb = ev->obj;
        callback(ctx, iocb, ev->res, ev->res2);
      }

      if (n == 0 || cnt == n_requests)
        break;
    }

    for (int i = 0; i < n_requests; i++) {
      delete iocbs[i];
      free(bufs[i]);
    }
    delete[] iocbs;
    delete[] bufs;
    r = io_destroy(ctx);
    assert(r == 0);
  }
}

static double 
gettimeofday_sec()
{
  struct timeval tv; 
  gettimeofday(&tv, NULL);
  return tv.tv_sec + (double)tv.tv_usec*1e-6;
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

static inline off_t random_range(off_t min, off_t max) 
{
  return min + (rand() * (max - min + 1.0) / ((off_t) RAND_MAX + 1));
}
