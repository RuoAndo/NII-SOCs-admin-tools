date=`date --date '2 day ago' +%Y%m%d`

rm -rf tmp2
touch tmp2

ls $date | grep daily > dlist
while read line; do
    echo $line
    cat $date/$line >> tmp2
done < dlist

rm -rf dlist

cat tmp2 | grep -v travdirtime | grep -v Total | grep -v Max > ${date}_all

/root/hadoop-2.7.1/bin/hadoop fs -rmr RDCD
/root/hadoop-2.7.1/bin/hadoop fs -rmr tmp3

\cp ${date}_all tmp3

/root/hadoop-2.7.1/bin/hadoop fs -put tmp3
/root/pig-0.16.0/bin/pig -param SRCS=tmp3 reduce10.pig > tmp4
\cp tmp4 ${date}_reduced

rm -rf RDCD
/root/hadoop-2.7.1/bin/hadoop fs -get RDCD

python iplist.py tmp4 > iplist_${date}

rm -rf pig_*

