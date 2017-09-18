./build.sh rand-labeling
./build.sh avg
./build.sh relabel

split -l 300000 $1 out
ls out* > list
#head -n 20 list > list-20
#./rename.sh list-20
time ./rename.sh list
echo "now initlializing labels ..."
time ./rand-labeling 500000 5
