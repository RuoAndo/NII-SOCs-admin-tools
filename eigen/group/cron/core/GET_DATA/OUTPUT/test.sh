#date=`date --date '2 day ago' +%Y%m%d`
date=`date --date '1 day ago' +%Y%m%d`

rm -rf bar.*
rm -rf barlist
rm -rf list

ls $date > list
#split -l $(expr $(wc -l list | cut -d " " -f 1) / 2 + 1) list bar.
split -n 3 list bar.

ls bar.* > barlist

rm -rf ${date}_0
rm -rf ${date}_1
rm -rf ${date}_2

mkdir ${date}_0
mkdir ${date}_1
mkdir ${date}_2

COUNTER=0
for line in `cat barlist`
do
    for line2 in `cat $line`
    do
	echo $line2 "->" $COUNTER
	cp ${date}/$line2 ${date}_$COUNTER
    done

    COUNTER=`expr $COUNTER + 1`
done 
