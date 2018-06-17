if [ "$1" = "" ]
then
    echo "./test-command.sh INTERVAL"
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

comstr="timeout $INTVL /root/.pyenv/shims/python scr-interval-full-test.py \"$dsrc\" \"$d\""
echo $comstr
eval $comstr 
