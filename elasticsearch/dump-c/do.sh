#!/bin/bash
count=1000

SLICE_SIZE=1024

gcc -o dump dump.c -lpthread -lcurl -ljansson
gcc -o read read.c -lpthread -lcurl -ljansson

rm -rf log-read

while true
do
    echo $count
    rm -rf f*; time ./dump $SLICE_SIZE $count; time ./read 2>&1 | tee -a log-read
    count=`expr $count + 1000`
    if [ $count -eq 11000 ]; then
	exit 0
    fi
done

