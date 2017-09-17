./build.sh rand-labeling
./build.sh avg

echo "now initlializing labels ..."
time ./rand-labeling 500000 5
echo "now calculating centroids ..."
time ./avg 500000 6 # on *.labled
