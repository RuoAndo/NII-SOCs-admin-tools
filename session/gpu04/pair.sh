DATE=`date --date '4 day ago' +%Y%m%d`
./build-gpu.sh reduce
echo $DATE
time nLines=`wc -l trans-pair-all-${DATE} | cut -d " " -f 1`
echo $nLines

rm -rf x*
split -l 300000000 trans-pair-all-${DATE}

ls x* > list

rm -rf pair-${DATE}
touch pair-${DATE}

while read line; do
    echo $line
    time nLines=`wc -l $line | cut -d " " -f 1`
    echo $nLines
    comstr="./reduce $line $nLines"
    echo $comstr
    eval $comstr
    head -n 1000 tmp-pair >> pair-${DATE}
done < list

time ./sort-pair.pl pair-${DATE} > tmp-pair-sorted
cp tmp-pair-sorted tmp-pair-sorted-${DATE}
scp tmp-pair-sorted-${DATE} 192.168.72.6:/mnt/sdc/splunk-ip-pair/
