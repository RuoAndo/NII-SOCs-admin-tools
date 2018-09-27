./build.sh timestamp5

time split -l 200000000 all-org
ls x* > list

rm -rf timestamp-all
touch timestamp-all

while read line; do
    echo $line
    nLines=`wc -l $line | cut -d " " -f 1`
    ./timestamp5 $line $nLines
    cat tmp-timestamp-5 >> timestamp-all
done < list

