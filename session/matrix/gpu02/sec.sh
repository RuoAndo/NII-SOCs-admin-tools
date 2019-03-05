# about 4 min
#trans-pair-all-20190301

DATE=`date --date '4 day ago' +%Y%m%d`  
echo $DATE
#cp ${DATE}/all-org .

rm -rf x*

time split -l 100000000 all
./build-gpu.sh 8
./build-gpu.sh 9

rm -rf tmp-all
touch tmp-all

ls x* > list
while read line; do
    echo $line
    nLines=`wc -l $line | cut -d " " -f 1`
    echo $nLines
    CUDA_VISIBLE_DEVICES=2 ./8 $line $nLines
    cat tmp >> tmp-all
done < list

nLines=`wc -l tmp-all | cut -d " " -f 1`

#DATETIME=`date +%Y%m%d_%H%M%S`
#DATETIME=`date +%Y%m%d`
time CUDA_VISIBLE_DEVICES=2 ./9 tmp-all $nLines
cp tmp sec-${DATE}
cp raw raw-${DATE}

#scp sec-${DATE} 192.168.72.6:/mnt/sdc/splunk-sec/gpu03/store/
#scp sec-${DATE} 192.168.72.6:/mnt/sdc/splunk-sec/gpu03/current
#scp raw-${DATE} 192.168.72.6:/mnt/sdc/splunk-sec/gpu03/raw/

#mv sec-${DATE} ./backup/
#mv raw-${DATE} ./backup/
