#./getDataCsv.sh SESSION "2017/10/20 00:00" "2017/10/21 00:00"

currentDate=`date "+%Y%m%d-%H%M%S"`

echo "GET_DATA start:" $currentDate

today=$(date "+%Y/%m/%d")
day=`date --date '1 day ago' +%Y/%m/%d`
str=`echo ./getDataCsv.sh "SESSION " \\"$day "00:00"\\" \\"$today "00:00"\\"`
echo $str 
eval ${str}

echo "GET_DATA finished:" $currentDate

######

cd OUTPUT
lsn=`ls -1t *.csv | head -1`
echo $lsn

wcl=`wc -l $lsn | cut -d " " -f 1`
echo $wcl

nline=210000000

if [ $wcl -gt $nline ] ; then
   head -n 210000000 $lsn > $lsn.tmp
   \cp $lsn.tmp $lsn
fi

today=$(date "+%Y%m%d")
split -l 10000000 $lsn $today

mkdir $today 
mv $today* ./$today/

cd ..
