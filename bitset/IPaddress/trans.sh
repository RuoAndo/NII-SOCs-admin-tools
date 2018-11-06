# about 4 min
DATE=`date --date '3 day ago' +%Y%m%d`  
echo $DATE
cp ${DATE}/all-org .

./build.sh trans-vector6
./build.sh trans-vector7

rm -rf x*

time split -l 100000000 all-org

rm -rf trans-pair-all
touch trans-pair-all

ls x* > list
while read line; do
    echo $line
    ./trans-vector6 $line 100000000
    cat trans >> trans-pair-all
done < list

rm -rf trans-src-dst-all
touch trans-src-dst-all

ls x* > list
while read line; do
    echo $line
    ./trans-vector7 $line 100000000
    cat trans >> trans-src-dst-all
done < list

cp trans-pair-all trans-pair-all-${DATE}
cp trans-src-dst-all trans-src-dst-all-${DATE}

scp trans-pair-all-${DATE} 192.168.76.210:/mnt/data/matrix
scp trans-src-dst-all-${DATE} 192.168.76.210:/mnt/data/matrix

scp trans-pair-all-${DATE} 192.168.76.212:/mnt/data2/matrix
scp trans-src-dst-all-${DATE} 192.168.76.212:/mnt/data2/matrix

