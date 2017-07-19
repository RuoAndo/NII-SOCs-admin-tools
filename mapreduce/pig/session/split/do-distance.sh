g++ distance3.cpp

rm -rf clstmp
touch clstmp

while read line; do
    wc=`wc -l $line`
    wc2=`echo $wc | cut -d " " -f 1`
    echo $wc2
    python trans.py $line > $line-trans
    echo "processing $line-trans.."
    ./a.out cat-avg-all 5 4 $line-trans $wc2 6 >> clstmp
done < $1

