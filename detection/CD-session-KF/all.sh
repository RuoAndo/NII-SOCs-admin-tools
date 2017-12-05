if [ "$2" = "" ]
then
    echo "no argument: time ./all.sh 2017 10 15"
    exit
fi

make
cp -r /mnt/count-session /root/
cp -r /data1/count-session /root/
./cp.sh
#time ./install.sh
time ./do-gendata.sh list instIDlist  
time ./auto.sh instIDlist $1 $2 $3
