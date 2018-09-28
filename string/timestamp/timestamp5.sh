./build.sh timestamp5

time split -l 500000000 all-org
ls x* > list

rm -rf timestamp-all
touch timestamp-all

while read line; do
    echo $line
    nLines=`wc -l $line | cut -d " " -f 1`
    ./timestamp5 $line $nLines
    cat tmp-timestamp >> timestamp-all
done < list

