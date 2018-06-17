if [ "$1" = "" ]
then
    echo "./scatter-cls.sh INTERVAL"
    exit
fi

INTVL=$1

date7=`date --date '2 day ago' +%Y/%m/%d`
dsrc="$date7 00:00:00" 
echo $dsrc

date7_track=`date --date '2 day ago' +%Y%m%d`

d0=`date "+%s" --date "${dsrc}"`
d=`date "+%Y/%m/%d %T" -d @"$d0"`
dsrc=$d

COUNT=0

#pyenv local 3.4.7

while [ $COUNT -lt 24 ]; do

    dtrack=`date "+%Y%m%d%H%M%S" -d @"$d0"`
    storedir=`date "+%Y%m%d" -d @"$d0"`

    d0=`date "+%s" --date "${d}"`
    d0=`expr $d0 + 3600`

    d=`date "+%Y/%m/%d %T" -d @"$d0"`
    comstr="timeout $INTVL /root/.pyenv/shims/python scr-interval-full.py \"$dsrc\" \"$d\" > $dtrack"
    #comstr="timeout $INTVL /root/.pyenv/shims/python scr-interval-full.py \"$dsrc\" \"$d\""
    echo $comstr
    eval $comstr

    mkdir ${storedir}
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

#cp all ../../../clustering/pclstr2 
cp all ../
