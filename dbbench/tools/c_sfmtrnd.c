#include <stdio.h>
#include <stdlib.h>

#include "SFMT.h"

static inline off_t random_range(uint64_t n, off_t min, off_t max);

int main(int argc, char *argv[])
{
  if (argc != 3) {
    printf("%s num max\n", argv[0]);
    exit(1);
  }

  off_t num = atoll(argv[1]);
  off_t max = atoll(argv[2]);

  sfmt_t sfmt;
  uint64_t r;

  sfmt_init_gen_rand(&sfmt, 4321);

  for (int i = 0; i < num; ++i) {
    r = sfmt_genrand_uint64(&sfmt);
    printf("%20"PRIu64 "\n", random_range(r, 0, max));
  }

  return 0;
}

static inline off_t random_range(uint64_t n, off_t min, off_t max) 
{
  return min + (n * (max - min + 1.0) / ((off_t) RAND_MAX + 1));
}
