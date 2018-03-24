COUNTER=0
COUNTER_BAK=0
a=0

while [ $a -ne 10 ]
do
    time python sse.py diff-COUNTER_BAK diff-COUNTER
    ls *.labeled > list-labeled
    ./cat-labeled.sh list-labeled 
    time python 0.py all-relabeled | tee diff-COUNTER_BAK
    echo "calculating centroid..."
    time ./avg 500000 6 # on *.labled
    time ./relabel centroid 10 3 500000 6 # on *.labeled to *.relabeled
    time ./cat-relabeled.sh list-relabeled 
    echo "counting points per cluster..."
    time python 0.py all-relabeled
    echo "converting *.labeled to *.relabeled..."
    time ./rename2.sh list-relabeled | tee diff-COUNTER
    COUNTER=`expr $COUNTER + 1`
    COUNTER_BAK=`expr $COUNTER - 1`
done
