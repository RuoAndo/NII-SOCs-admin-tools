DATE=`date --date '4 day ago' +%Y%m%d`
./build-gpu.sh reduce
./build-gpu.sh reduce2
echo $DATE
time nLines=`wc -l trans-src-dst-all-${DATE} | cut -d " " -f 1`
echo $nLines

rm -rf x*
split -l 100000000 trans-src-dst-all-${DATE}

ls x* > list

rm -rf tmp-all
touch tmp-all 

while read line; do
    echo $line
    time nLines=`wc -l $line | cut -d " " -f 1`
    echo $nLines
    comstr="CUDA_VISIBLE_DEVICES=1 ./reduce $line $nLines"
    echo $comstr
    eval $comstr
    cat tmp-reduced-dst >> tmp-all
done < list

nLines=`wc -l tmp-all | cut -d " " -f 1`
echo $nLines
time CUDA_VISIBLE_DEVICES=1 ./reduce2 tmp-all $nLines ${DATE}
cp tmp-reduced-dst-final dstIP-${DATE}

scp dstIP-${DATE} 192.168.72.6:/mnt/sdc/splunk-ip/dst
