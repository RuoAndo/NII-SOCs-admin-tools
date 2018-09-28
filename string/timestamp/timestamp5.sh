if [ "$1" = "" ]
then
    echo "./timestamp5.sh nLines"
    exit 1
fi

./build.sh timestamp5

time split -l $1 all-org
ls x* > list

rm -rf timestamp-all
touch timestamp-all

while read line; do
    echo $line
    nLines=`wc -l $line | cut -d " " -f 1`
    ./timestamp5 $line $nLines
    cat tmp-timestamp >> timestamp-all
done < list

