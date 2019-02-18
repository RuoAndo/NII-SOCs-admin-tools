./build-gpu.sh reduce
./build-gpu.sh reduce2

echo "counting lines..."
wc -l $1

split -l 200000000 $1
ls x* > list

rm -rf tmp-all
touch tmp-all

while read line; do
    echo $line
    nLines=`wc -l $line | cut -d " " -f 1`
    ./reduce $line $nLines
    cat tmp >> tmp-all
done < list

nLines=`wc -l tmp-all | cut -d " " -f 1`
./reduce2 tmp-all $nLines
#cp tmp tmp-final
