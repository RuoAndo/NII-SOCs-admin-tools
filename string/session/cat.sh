ls *.csv > list-csv

rm -rf all
touch all

while read line; do
    echo $line
    cat $line >> all
done < list-csv
