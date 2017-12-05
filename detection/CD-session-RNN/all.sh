if [ "$2" = "" ]
then
    echo "no argument: ./all.sh epoch 2017 10 15" 
    exit
fi

./cp.sh
cp -r /mnt/count-session /root/
cp -r /data1/count-session /root/
#time ./install.sh
time ./do-gendata.sh list instIDlist 
time ./auto.sh instIDlist $1 $2 $3 $4
