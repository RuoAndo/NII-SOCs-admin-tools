./build.sh rand-labeling
./build.sh avg
#./build.sh relabel

split -l 500000 $1 out
# ls out* > list
#./rename.sh list
echo "now initlializing labels ..."
time ./rand-labeling 500000 5
time ./avg 500000 6 # on *.labled
