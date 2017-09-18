./build.sh rand-labeling
./build.sh avg
./build.sh relabel

split -l 500000 all out
ls out* > list
head -n 20 list > list-20
./rename.sh list-20
echo "now initlializing labels ..."
time ./rand-labeling 500000 5
