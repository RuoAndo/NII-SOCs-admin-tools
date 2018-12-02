head -n 2100000000 all-whole > all-org-cut
nLines=300000000

./build-gpu.sh group10
echo "now spliting..."

rm -rf x*
split -l $nLines all-org-cut

ls xa* > list

rm -rf result-all
touch result-all

while read line; do
    echo $line
    split -d -l 10000000 $line
    ./group10 116.214.87.171 $nLines
    \cp result result.${line}
    cat result >> result-all
done < list

