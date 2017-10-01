rm -rf *.trans

ls 20*.csv > csvlist
./sort_hibetsu.pl csvlist > csvlist-sorted

while read line; do
    echo $line
    python trans.py $line > $line.trans 
done < csvlist-sorted
