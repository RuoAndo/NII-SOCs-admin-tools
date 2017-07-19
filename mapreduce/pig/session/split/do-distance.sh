g++ distance3.cpp

while read line; do
    wc=`wc -l $line`
    wc2=`echo $wc | cut -d " " -f 1`
    echo $wc2
    python trans.py $line > $line-trans
    ./a.out cat-avg-all 5 4 $line-trans $wc2 6
done < $1

