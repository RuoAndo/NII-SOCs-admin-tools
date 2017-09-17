./build.sh rand-labeling
./build.sh avg
./build.sh relabel

split -l 500000 $1 out
ls out* > list
./rename.sh list
