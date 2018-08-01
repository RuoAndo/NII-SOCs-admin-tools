ls *.csv > list-csv

date=`head -n 1 list-csv | cut -d "_" -f 2`
echo $date

rm -rf all-port-${date}
touch all-port-${date}

while read line; do
    echo $line
    ./cut-port.sh $line >> all-port-${date}
done < list-csv


