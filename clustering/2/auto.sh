time python rand7.py 6 10000000 10000 > tmp-1000-1
time ./zero.sh tmp-1000-1 5000  # 6000 Threads
cp reduced reduced-1000-1-5000
time ./zero.sh tmp-1000-1 10000  # 3000 Threads
cp reduced reduced-1000-1-10000
time ./zero.sh tmp-1000-1 100000  # 300 Threads
cp reduced reduced-1000-1-100000
