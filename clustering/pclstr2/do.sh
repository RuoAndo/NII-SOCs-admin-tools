./iostat.sh /dev/mapper/iST_nls-data1 > tmp2 &
vmstat 1 > tmp &

time ./second.sh

echo "### vmstat ###"
./aggregate-vmstat.sh tmp
kill -9 $!

echo "### iostat ###"
./aggregate-iostat.sh tmp2

TARGET=iostat
pids=(`ps -ef | grep ${TARGET} | grep -v grep | awk '{ print $2; }'`)
for pid in ${pids[*]}
do
kill -9 ${pid}
done



