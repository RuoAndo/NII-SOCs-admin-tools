if [ "$1" = "" ]
then
    echo "./scatter4.sh interval"
    exit
fi

interval=$1

#nThreads=$1
#echo "nThreads:"$nThreads

date7=`date --date '1 day ago' +%Y/%m/%d`
dsrc="$date7 00:00:00" 
echo $dsrc

date7_track=`date --date '2 day ago' +%Y%m%d`

d0=`date "+%s" --date "${dsrc}"`
d=`date "+%Y/%m/%d %T" -d @"$d0"`
dsrc=$d

COUNT=0

/root/.pyenv/bin/pyenv global 3.4.7

storedir=`date "+%Y%m%d" -d @"$d0"`
mkdir ${storedir}

while [ $COUNT -lt 24 ]; do
#while [ $COUNT -lt 2 ]; do

    dtrack=`date "+%Y%m%d%H%M%S" -d @"$d0"`

    d0=`date "+%s" --date "${d}"`
    d0=`expr $d0 + 3600`

    d=`date "+%Y/%m/%d %T" -d @"$d0"`
    comstr="timeout $interval /root/.pyenv/shims/python scr-interval.py \"$dsrc\" \"$d\" > $dtrack"

    echo $comstr
    eval $comstr

    mv $dtrack ./${storedir}
    dsrc=$d

    COUNT=`expr $COUNT + 1` 
done

cd ./${storedir}

ls 201* > list

rm -rf all-${storedir}
touch all-${storedir}

COUNT=0
while read line; do
    echo $line
    cat $line >> all-${storedir}
    COUNT=`expr $COUNT + 1`
done < list

rm -rf ../../../clustering/pclstr2/all*
cp all-${storedir} ../../../clustering/pclstr2/
cp all-* ../../../clustering/pclstr2/

