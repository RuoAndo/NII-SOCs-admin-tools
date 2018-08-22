#time ./getSessionDataCSv.sh "2018/07/15 00:00" "2018/07/16 00:00"

dd=`date --date '2 day ago' +%Y/%m/%d`
START=`echo "$dd 00:00"`

d=`date --date '1 day ago' +%Y/%m/%d`
END=`echo "$d 00:00"`

ddDIR=`date --date '2 day ago' +%Y%m%d`
mkdir $ddDIR
mv *.csv ./$ddDIR

cp *.sh ./$ddDIR
cp *.cpp ./$ddDIR
cp *.h ./$ddDIR
cp *.hpp ./$ddDIR

cd ./$ddDIR
./cat.sh

nLines=`wc -l all | cut -d " " -f 1`
echo $nLines

echo "count_dest_port"
./build.sh count_dest_port.cpp 
./a.out all $nLines

echo "count_source_port"
./build.sh count_source_port.cpp 
./a.out all $nLines

cd ..
scp -r $ddDIR 192.168.76.203:
scp -r $ddDIR 192.168.76.210:/mnt/data/
