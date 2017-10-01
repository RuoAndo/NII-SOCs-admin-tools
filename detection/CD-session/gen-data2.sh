# time ./do-gendata.sh daylist instIDlist  

rm -rf in_*
rm -rf out_*

ls *.trans > translist
./sort_hibetsu.pl translist > translist-sorted

while read line; do
    echo $line
    python gen-data2.py instlist $line
done < translist-sorted
