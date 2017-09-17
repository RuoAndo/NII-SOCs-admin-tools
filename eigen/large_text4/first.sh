./build.sh rand-labeling
./build.sh avg
./build.sh relabel

split -l 500000 all out
ls out* > list
./rename.sh list
echo "now initlializing labels ..."
time ./rand-labeling 500000 5
