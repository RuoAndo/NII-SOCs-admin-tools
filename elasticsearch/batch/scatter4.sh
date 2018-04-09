# requires: scr-interval.py
# comstr="timeout $INTERVAL python scr-interval.py \"$dsrc\" \"$d\" > $dtrack"

if [ "$3" = "" ]
then
    echo "./scatter4.sh interval"
    exit
fi

INTERVAL=$1

date7=`date --date '2 day ago' +%Y/%m/%d`
dsrc="$date7 00:00:00" 
echo $dsrc

date7_track=`date --date '2 day ago' +%Y%m%d`

d0=`date "+%s" --date "${dsrc}"`
d=`date "+%Y/%m/%d %T" -d @"$d0"`
dsrc=$d

storedir=`date "+%Y%m%d" -d @"$d0"`
rm -rf ${storedir}
mkdir ${storedir}

#pyenv local 3.4.7

COUNT=0
while [ $COUNT -lt 24 ]; do

    d0=`date "+%s" --date "${d}"`
    d0=`expr $d0 + 3600`

    d=`date "+%Y/%m/%d %T" -d @"$d0"`
    dtrack=`date "+%Y%m%d%H%M%S" -d @"$d0"`

    comstr="timeout $INTERVAL python scr-interval.py \"$dsrc\" \"$d\" > $dtrack"
    echo $comstr
    eval $comstr

    mv $dtrack ./${storedir}
    dsrc=$d

    COUNT=`expr $COUNT + 1` 
done

cd ${storedir}

ls 201* > list

rm -rf all
touch all

COUNT=0
while read line; do
    echo $line
    cat $line >> all
    COUNT=`expr $COUNT + 1`
done < list

cp all ../../../clustering/pclstr2/

