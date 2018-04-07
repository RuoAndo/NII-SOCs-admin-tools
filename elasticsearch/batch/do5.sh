ls 201* > list

rm -rf all
touch all

COUNT=0
while read line; do
    echo $line
    cat $line >> all
    COUNT=`expr $COUNT + 1`
done < list

echo "now splitting..."
rm -rf *.spl; split -l 10000 all 0 --additional-suffix=.spl -d -a 5

./build.sh group11
time ./group11

cp all ../../../clustering/pclstr2/
