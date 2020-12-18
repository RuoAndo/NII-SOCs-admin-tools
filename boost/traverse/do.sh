rm -rf log-100000000-100-20
vmstat -n 1 | tee log-100000000-100-20 &
time ./boost tmp-box/ list-sample
pkill vmstat
 
