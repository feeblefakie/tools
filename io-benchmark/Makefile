prog=sequential sequentialw sequentialw_fsync random random_range random_aio random32 random_aio32 randomw interface seek seekw latency latencyw sim postmark interface-para interface-para-seq
#CPPFLAGS=-O2 -Wall -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64
CPPFLAGS=-O2 -Wall -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64

all: $(prog)

postmark: postmark-1_5.c
	gcc $(CPPFLAGS) $< -o $@

sequential: sequential.cpp
	g++ $(CPPFLAGS) $< -o $@

sequentialw: sequentialw.cpp
	g++ $(CPPFLAGS) $< -o $@

sequentialw_fsync: sequentialw_fsync.cpp
	g++ $(CPPFLAGS) $< -o $@

random: random.cpp
	g++ $(CPPFLAGS) -lpthread $< -o $@

random_range: random_range.cpp
	g++ $(CPPFLAGS) -lpthread $< -o $@

random_aio: random_aio.cpp
	g++ $(CPPFLAGS) -lpthread -laio $< -o $@

random32: random32.cpp
	g++ $(CPPFLAGS) -lpthread $< -o $@

random_aio32: random_aio32.cpp
	g++ $(CPPFLAGS) -lpthread -laio $< -o $@

randomw: randomw.cpp
	g++ $(CPPFLAGS) -lpthread $< -o $@

interface: interface.cpp
	g++ $(CPPFLAGS) -lpthread $< -o $@

interface-para: interface-para.cpp
	g++ $(CPPFLAGS) -lpthread $< -o $@

interface-para-seq: interface-para-seq.cpp
	g++ $(CPPFLAGS) -lpthread $< -o $@

seek: seek.cpp
	g++ $(CPPFLAGS) $< -o $@

seekw: seekw.cpp
	g++ $(CPPFLAGS) $< -o $@

latency: latency.cpp
	g++ $(CPPFLAGS) $< -o $@

latencyw: latencyw.cpp
	g++ $(CPPFLAGS) $< -o $@

sim: sim.cpp
	g++ $(CPPFLAGS) $< -o $@

clean:
	rm -rf *.o $(prog)
