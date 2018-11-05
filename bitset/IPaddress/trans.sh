# about 4 min
DATE=`date --date '3 day ago' +%Y%m%d`  
echo $DATE
cp ${DATE}/all-org .

./build.sh trans-vector6

time split -l 100000000 all-org

rm -rf trans-all
touch trans-all

ls x* > list
while read line; do
    echo $line
    ./trans-vector6 $line 100000000
    cat trans >> trans-all
done < list
