# about 4 min
#time split -l 100000000 all-org
./build-gpu.sh 6

rm -rf tmp-all
touch tmp-all

ls x* > list
while read line; do
    echo $line
    ./6 $line 100000000
    cat tmp >> tmp-all
done < list
