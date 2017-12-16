cd OUTPUT
lsn=`ls -1t *.csv | head -1`
echo $lsn

today=$(date "+%Y%m%d")
split -l 10000000 $lsn $today

cd ..
