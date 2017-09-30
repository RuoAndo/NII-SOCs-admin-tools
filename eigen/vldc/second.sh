<<<<<<< HEAD
=======
NC=20
>>>>>>> 816c3d96107606a7228acd00dbba2a6b1699daef
nItems=5
LN=500000
NC=20

echo "STEP1: concatenating label files ..." 
ls /dev/vldc_label* > list-labeled
./cat-labeled.sh list-labeled # yields all-labeled

echo "STEP2: counting points per cluster..."
time python 0.py all-labeled | tee tmp-all-labeled #test
#time python 0.py all-labeled | tee tmp-all-labeled
sleep 2s

<<<<<<< HEAD
echo "STEP3: calculating centroid..."
time ./avg $LN $nItems # on *.labled # yields file "centroid"
#time ./avg 500000 6 # on *.labled
=======
echo "STEP3: calculating centroid... "


time ./avg $LN $NC # on *.labled # yields file "centroid"
>>>>>>> 816c3d96107606a7228acd00dbba2a6b1699daef
sleep 2s

echo "STEP4: filling blank centroid..."
#python fill.py tmp-all-labeled centroid > tmp-centroid
python fill2.py tmp-all-labeled centroid > tmp-centroid
cat tmp-centroid
\cp tmp-centroid centroid
sleep 4s

<<<<<<< HEAD
echo "STEP5: relabeling ..."
=======
echo "STEP5: relabeling ... | centroid N*M data X*Y"
>>>>>>> 816c3d96107606a7228acd00dbba2a6b1699daef
time ./relabel centroid $NC 3 $LN $nItems # on *.labeled to *.relabeled

# concatenate
time ls /dev/vldc_relabel* > list-relabeled
#./sort.pl list-relabeled > list-relabeled-sorted 
time ./cat-relabeled.sh list-relabeled # yields all-relabeled

echo "STEP5: counting points per cluster..."
time python 0.py all-relabeled | tee tmp-all-relabeled
sleep 2s

echo "STEP6: converting *.labeled to *.relabeled..."
#time ./rename2.sh list-relabeled-20 # test
time ./rename2.sh list-relabeled

echo "STEP7: calculating SSE..."
time python sse.py centroid tmp-all-relabeled tmp-all-labeled
#cat SSE
sleep 2s
