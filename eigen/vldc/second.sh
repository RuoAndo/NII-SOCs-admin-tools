# cluster size
nClusters=20

# data size
nLines=500000
nDimensions=5

nThreads=100

# items: src dst n[* * *] 
nItems=3 # nDimensions-2

echo "STEP1: building executables ..."
./build.sh init-label
./build.sh avg
./build.sh relabel
./build.sh fill2

echo "STEP1: concatenating label files ..." 
ls /dev/vldc_label* > label_file_list
head -n $nThreads label_file_list > label_file_list.h
./cat-labeled.sh label_file_list.h # yields all-labeled

echo "STEP2: counting points per cluster..."
time python 0.py all-labeled $nClusters | tee tmp-all-labeled 
sleep 2s

echo "STEP3: calculating centroid..."
time ./avg $nLines $nDimensions
sleep 2s

echo "STEP4: filling blank centroid rows..."
python fill2.py tmp-all-labeled centroid > tmp-centroid
cat tmp-centroid
\cp tmp-centroid centroid
sleep 4s

echo "STEP5: relabeling ..."
time ./relabel centroid $nClusters $nItems $nLines $nDimensions 

echo "STEP6: concatenating relabel files ..."
time ls /dev/vldc_relabel* > list-relabeled
head -n $nThreads list-relabeled > list-relabeled.h
time ./cat-relabeled.sh list-relabeled.h # yields all-relabeled

echo "STEP7: counting points per cluster..."
time python 0.py all-relabeled $nClusters | tee tmp-all-relabeled
sleep 2s

echo "STEP8: converting *.labeled to *.relabeled..."
time ./rename2.sh list-relabeled.h # from STEP6

# comparing STEP2 with STEP7
echo "STEP7: calculating SSE..."
time python sse.py centroid tmp-all-relabeled tmp-all-labeled
#cat SSE
sleep 2s
