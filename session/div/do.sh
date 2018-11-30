#head -n 1500000000 all-org > all-org-cut
nLines=300000000

./build-gpu.sh group10
#echo "now spliting..."
#split -l 300000000 all-org-cut

ls xa* > list

rm -rf result-all
touch result-all

while read line; do
    echo $line
    split -d -l 10000000 $line
    ./group10 133.92.253.33 $nLines
    \cp result result.${line}
    cat result >> result-all
done < list

