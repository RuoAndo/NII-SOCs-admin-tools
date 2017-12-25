# cluster size
nClusters=20

# data size
nLines=10000000

nDimensions=6
nItems=4 # nDimensions-2 / items: src dst n[* * *] 

nThreads=15

echo "STEP0: building executables ..."
./build.sh init-label
./build.sh avg
./build.sh relabel
./build.sh fill2
./build.sh count
./build.sh pickup2

echo "STEP5: relabeling ..."
time ./relabel centroid $nClusters $nItems $nLines $nDimensions 

echo "STEP6: concatenating relabel files ..."
time ls *.rlbl > list-relabeled
./sort.pl list-relabeled > list-relabeled-sorted
head -n $nThreads list-relabeled-sorted > list-relabeled.h
time ./cat-relabeled.sh list-relabeled.h # yields all-relabeled

echo "STEP8: converting *.labeled to *.relabeled..."
time ./rename2.sh list-relabeled.h # from STEP6

echo "STEP7: counting points per cluster..."
#time python 0.py all-relabeled $nClusters | tee tmp-all-relabeled
time ./count $nLines 1 | tee tmp-all-relabeled 
sleep 2s

# comparing STEP2 with STEP7
echo "STEP7: calculating SSE..."
time python sse.py centroid tmp-all-relabeled tmp-all-labeled
#cat SSE
sleep 2s

./build.sh pickup2; ./pickup2 centroid $nClusters $nItems $nLines $nDimensions | tee tmp
python reverse.py tmp
