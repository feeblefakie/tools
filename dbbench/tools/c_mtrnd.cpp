#include <ctime>
#include <iostream>
#include <boost/random.hpp>

int main(int argc, char *argv[])
{
  if (argc != 3) {
    printf("%s num max\n", argv[0]);
    exit(1);
  }

  off_t num = atoll(argv[1]);
  off_t max = atoll(argv[2]);

  boost::mt19937 gen(static_cast<unsigned long>(time(0)));
  boost::uniform_int<> dst(0, max);
  boost::variate_generator< boost::mt19937&, boost::uniform_int<> > rand(gen, dst);

  for (int i = 0; i < num; ++i) {
    std::cout << rand() << std::endl;
  }

  return 0;
}

