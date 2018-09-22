./build.sh trans3

ls *.csv > list-csv

rm -rf transip-all
touch transip-all

while read line; do
    echo $line
    nLines=`wc -l $line | cut -d " " -f 1`
    time ./trans3 $line $nLines
    cat transip >> transip-all
done < list-csv

