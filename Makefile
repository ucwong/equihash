OPT   = -O3
FLAGS = -Wall -Wno-deprecated-declarations -D_POSIX_C_SOURCE=200112L $(OPT) -pthread 
GPP   = g++ -march=native -m64 -std=c++11 $(FLAGS)

all:	equi equi1 faster faster1 verify test spark

equi:	equi.h equi_miner.h equi_miner.cpp Makefile
	$(GPP) -DATOMIC equi_miner.cpp blake/blake2b.cpp -o equi

equi1:	equi.h equi_miner.h equi_miner.cpp Makefile
	$(GPP) -DSPARK equi_miner.cpp blake/blake2b.cpp -o equi1

equi1g:	equi.h equi_miner.h equi_miner.cpp Makefile
	g++ -g -DSPARK equi_miner.cpp blake/blake2b.cpp -pthread -o equi1g

faster:	equi.h equi_miner.h equi_miner.cpp Makefile
	$(GPP) -DJOINHT -DATOMIC equi_miner.cpp blake/blake2b.cpp -o faster

faster1:	equi.h equi_miner.h equi_miner.cpp Makefile
	$(GPP) -DJOINHT equi_miner.cpp blake/blake2b.cpp -o faster1

equi965:	equi.h equi_miner.h equi_miner.cpp Makefile
	$(GPP) -DWN=96 -DWK=5 equi_miner.cpp blake/blake2b.cpp -o equi965

equi1445:	equi.h equi_miner.h equi_miner.cpp Makefile
	$(GPP) -DWN=144 -DWK=5 -DXWITHASH equi_miner.cpp blake/blake2b.cpp -o equi1445

eqcuda:	equi_miner.cu equi.h blake2b.cu Makefile
	nvcc -arch sm_35 equi_miner.cu blake/blake2b.cpp -o eqcuda

eqcuda1445:	equi_miner.cu equi.h blake2b.cu Makefile
	nvcc -DWN=144 -DWK=5 -DXWITHASH -arch sm_35 equi_miner.cu blake/blake2b.cpp -o eqcuda1445

feqcuda:	equi_miner.cu equi.h blake2b.cu Makefile
	nvcc -DUNROLL -DJOINHT -arch sm_35 equi_miner.cu blake/blake2b.cpp -o feqcuda

verify:	equi.h equi.c Makefile
	g++ -g equi.c blake/blake2b.cpp -o verify

bench:	equi
	time for i in {0..9}; do ./faster -n $$i; done

test:	equi verify Makefile
	time ./equi -h "" -n 0 -t 1 -s | grep ^Sol | ./verify -h "" -n 0

spark:	equi1
	time ./equi1

clean:	
	rm equi equi1 equi1g faster faster1 equi965 equi1445 eqcuda eqcuda1445 feqcuda verify
