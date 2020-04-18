#!/usr/bin/env bash
# because of unholy bullshit in the mnemosyne link system
# where link path is dependent on working directory
cd /u/wcai6/code/mnemosyne-gcc/usermode
scons --clean;scons --build-bench=memcached --clean;scons --build-bench=memcached
# all paths should be relative to here

mkdir -p mcd_test/results

threads=($(seq 6 7))
# threads=(1 2 4 8 16 24 32)
# threads=(32)
benches=("r5w5")
#benches=("r9w1" "r5w5")
#benches=("r1w9" "r5w5" "r9w1")


#threads=(8)
#benches=("r1w9")

BIN_PATH="/u/wcai6/code/mnemosyne-gcc/usermode/build/bench/memcached/memcached-1.2.4-mtm"

declare -A bins
bins=( \
#["mnemosyne"]="./build/bench/memcached/memcached-1.2.4-mtm/memcached -m 4096" \
# ["rp"]="${BIN_PATH}/memcached -m 4096" \
# ["mak"]="${BIN_PATH}/memcached -m 4096" \
["mne"]="${BIN_PATH}/memcached -m 4096" \
#["origin"]="${BIN_PATH}/memcached_origin -m 4096" \
)
#bins=( \
#["mnemosyne"]="./build/bench/memcached/memcached-1.2.4-mtm/memcached -m 4096" \
#["atlas"]="${BIN_PATH}/memcached_atlas -m 4096" \
#["ido"]="${BIN_PATH}/memcached_ido -m 4096" \
#["justdo"]="${BIN_PATH}/memcached_justdo -m 4096" \
#["origin"]="${BIN_PATH}/memcached_origin -m 4096" \
#)

#memaslap_cmd="./mcd_test/libmemcached-1.0.18/clients/memaslap -s 127.0.0.1:11211 -S 65s -t60s -T8 -c128"
#memaslap_cmd="./bench/memcached/libmemcached-0.45/clients/memslap -s 127.0.0.1:11211 -S 8s -t5s -c32"
memaslap_cmd="./bench/memcached/libmemcached-0.45/clients/memslap -s 127.0.0.1:11211 -S 25s -t10s -T32 -c128"

clean_cmd="rm -rf /dev/shm/* ; rm -rf /tmp/segments"

${clean_cmd}
for bench in "${benches[@]}"
do
    for thread in "${threads[@]}"
    do
        for bin in "${!bins[@]}"
        do
            for run in `seq 0 0`
            do
		${clean_cmd}
                sleep 2
		echo "${bins[$bin]} -t ${thread} 2> mcd_test/results/server-${bench}-${bin}-${thread}-${run} &"
                ${bins[$bin]} -t ${thread} 2> mcd_test/results/server-${bench}-${bin}-${thread}-${run} &
                sleep 1
                numactl --cpunodebind=1 ${memaslap_cmd}	-F ./mcd_test/${bench}.config > mcd_test/results/mcd-${bench}-${bin}-${thread}-${run}
                sleep 1
		kill -INT $!
            done
        done
    done
done
