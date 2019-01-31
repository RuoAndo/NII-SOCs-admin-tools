# about 4 min
DATE=`date --date '3 day ago' +%Y%m%d`  
echo $DATE
cp /data1/${DATE}/all-org .

./build.sh trans-vector6
./build.sh trans-vector7
./build.sh trans-vector8

rm -rf x*

time split -l 100000000 all-org

rm -rf trans-pair-all
touch trans-pair-all

#ls xa* > list
echo "xaa" > list
while read line; do
    echo $line
    ./trans-vector6 $line 100000000
    cat trans >> trans-pair-all
done < list

rm -rf trans-src-dst-all
touch trans-src-dst-all

#ls xa* > list
echo "xaa" > list
while read line; do
    echo $line
    ./trans-vector7 $line 100000000
    cat trans >> trans-src-dst-all
done < list

rm -rf trans-counts-bytes
touch trans-counts-bytes

#ls xa* > list
echo "xaa" > list
while read line; do
    echo $line
    ./trans-vector8 $line 100000000
    cat trans >> trans-counts-bytes
done < list

cp trans-pair-all trans-pair-all-${DATE}
cp trans-src-dst-all trans-src-dst-all-${DATE}
cp trans-counts-bytes trans-counts-bytes-${DATE}

scp trans-pair-all-${DATE} 192.168.76.210:/mnt/data/matrix/fsv03
scp trans-src-dst-all-${DATE} 192.168.76.210:/mnt/data/matrix/fsv03
scp trans-counts-bytes-${DATE} 192.168.76.210:/mnt/data/matrix/fsv03

scp trans-pair-all-${DATE} 192.168.76.212:/mnt/data2/matrix/fsv03
scp trans-src-dst-all-${DATE} 192.168.76.212:/mnt/data2/matrix/fsv03
scp trans-counts-bytes-${DATE} 192.168.76.212:/mnt/data2/matrix/fsv03

scp trans-pair-all-${DATE} 192.168.72.5:/mnt/sdc/matrix/fsv03
scp trans-src-dst-all-${DATE} 192.168.72.5:/mnt/sdc/matrix/fsv03
scp trans-counts-bytes-${DATE} 192.168.72.5:/mnt/sdc/matrix/fsv03

scp trans-pair-all-${DATE} 192.168.72.6:/mnt/sdc/matrix/fsv03
scp trans-src-dst-all-${DATE} 192.168.72.6:/mnt/sdc/matrix/fsv03
scp trans-counts-bytes-${DATE} 192.168.72.6:/mnt/sdc/matrix/fsv03

rm -rf trans-pair-all trans-pair-all-${DATE}
rm -rf trans-src-dst-all trans-src-dst-all-${DATE}
rm -rf trans-counts-bytes trans-counts-bytes-${DATE}

DATETIME=`date +%Y%m%d_%H%M%S_%3N`
echo $DATETIME
