#!/bin/bash

./build-gpu.sh atomic
./build-gpu.sh fine-coarse

#./a.out file data 1000 1000 3

MAX=100000
INTVL=500

echo "atomic"

rm -rf atomic.csv
touch atomic.csv

COUNT=10000
while [ $COUNT -lt $MAX ]; do
    rslt=`./atomic data2 ${COUNT} 10000 3`
    echo $rslt","$COUNT | tee -a atomic.csv
    COUNT=`expr $COUNT + $INTVL` # COUNT をインクリメント    
done

rm -rf fine-coarse.csv
touch fine-coarse.csv

echo "fine-coarse"
COUNT=10000
while [ $COUNT -lt $MAX ]; do
    rslt=`./fine-coarse data2 ${COUNT} 10000 3`
    echo $rslt","$COUNT | tee -a fine-coarse.csv
    COUNT=`expr $COUNT + $INTVL` # COUNT をインクリメント    
done

echo "thrust"
rm -rf thrust.csv
touch thrust.csv

COUNT=10000
while [ $COUNT -lt $MAX ]; do
    rslt=`./thrust data2 ${COUNT} 10000 3`
    echo $rslt","$COUNT | tee -a thrust.csv
    COUNT=`expr $COUNT + $INTVL` # COUNT をインクリメント
done

python plot3.py atomic.csv fine-coarse.csv thrust.csv 
cp plot3.png plot3.data.png
