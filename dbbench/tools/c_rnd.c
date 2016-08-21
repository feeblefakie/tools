#include <stdio.h>
#include <stdlib.h>

static inline off_t random_range(off_t min, off_t max);

int main(int argc, char *argv[])
{
  if (argc != 3) {
    printf("%s num max\n", argv[0]);
    exit(1);
  }

  off_t num = atoll(argv[1]);
  off_t max = atoll(argv[2]);

  for (int i = 0; i < num; ++i) {
    printf("%lld\n", random_range(0, max));
  }

  return 0;
}

static inline off_t random_range(off_t min, off_t max) 
{
  return min + (rand() * (max - min + 1.0) / ((off_t) RAND_MAX + 1));
}
