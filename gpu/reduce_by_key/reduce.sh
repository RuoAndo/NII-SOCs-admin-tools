rm -rf x*
time split -l 200000000 trans-all

./build-gpu.sh reduction-addr-src-dest-2
./build-gpu.sh reduction-addr-src-dest

ls x* > list

rm -rf reduced-all
touch reduced-all

while read line; do
    echo $line
    time ./reduction-addr-src-dest $line 200000000
    cp $line reduced.$line
    cat reduced >> reduced-all
done < list

nLines=`wc -l reduced-all | cut -d ' ' -f 1`
echo $nLines
time ./reduction-addr-src-dest-2 reduced-all $nLines

