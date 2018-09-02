ls *.csv > list-csv

date=`head -n 1 list-csv | cut -d "_" -f 2`
echo $date

#rm -rf all-${date}
#touch all-${date}

rm -rf all
touch all

while read line; do
    echo $line
    #./cut.sh $line >> all-${date}
    ./cut.sh $line >> all
done < list-csv

