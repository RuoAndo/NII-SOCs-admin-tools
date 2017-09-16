split -l 500000 all out
ls out* > list
./rename.sh list
./build.sh rand-labeling
time ./rand-labeling 500000 5
