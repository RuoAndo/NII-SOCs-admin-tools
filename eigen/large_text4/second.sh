#time python sse.py diff-COUNTER_BAK diff-COUNTER

echo "concatenating ..."
ls *.labeled > list-labeled
./cat-labeled.sh list-labeled # yields all-labeled

echo "counting points per cluster..."
time python 0.py all-labeled | tee tmp-all-labeled
sleep 2s

echo "calculating centroid..."
time ./avg 500000 6 # on *.labled
sleep 2s

echo "filling blank centroid..."
python fill.py tmp-all-labeled centroid > tmp-centroid
cat tmp-centroid
\cp tmp-centroid centroid
sleep 4s

# relabel
time ./relabel centroid 10 3 500000 6 # on *.labeled to *.relabeled

# concatenate
time ls *.relabeled > list-relabeled 
time ./cat-relabeled.sh list-relabeled 

echo "counting points per cluster..."
time python 0.py all-relabeled | tee tmp-all-relabeled
sleep 2s

echo "converting *.labeled to *.relabeled..."
time ./rename2.sh list-relabeled

echo "calculating SSE..."
time python sse.py centroid tmp-all-relabeled tmp-all-labeled
#cat SSE
sleep 2s
