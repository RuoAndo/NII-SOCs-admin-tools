#time ./getSessionDataCSv.sh "2018/07/15 00:00" "2018/07/16 00:00"

dd=`date --date '2 day ago' +%Y/%m/%d`
START=`echo "$dd 00:00"`

d=`date --date '1 day ago' +%Y/%m/%d`
END=`echo "$d 00:00"`

comstr=`echo time ./getSessionDataCSv.sh \"$START\" \"$END\"`
echo $comstr
eval $comstr

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

./build.sh count_dest_port 
./count_dest_port all $nLines

./build.sh count_source_port 
./count_source_port all $nLines

./build.sh count_source_ip
./count_source_ip all $nLines

./build.sh count_dest_ip 
./count_dest_ip all $nLines

./build.sh count_sourceIP_bytes 
./count_sourceIP_bytes all $nLines

./build.sh count_destIP_bytes 
./count_destIP_bytes all $nLines

cd ..
scp -r $ddDIR 192.168.76.203:
scp -r $ddDIR 192.168.76.210:/mnt/data/

echo $nLines
