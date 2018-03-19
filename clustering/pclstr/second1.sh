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

echo "STEP1: concatenating label files ..." 
ls *.lbl > label_file_list
./sort.pl label_file_list > label_file_list_sorted
head -n $nThreads label_file_list_sorted > label_file_list.h
./cat-labeled.sh label_file_list.h # yields all-labeled

echo "STEP2: counting points per cluster..."
#time python 0.py all-labeled $nClusters | tee tmp-all-labeled
time ./count $nLines 1 | tee tmp-all-labeled 
sleep 2s

echo "STEP3: calculating centroid..."
rm -rf centroid
time ./avg $nLines $nDimensions #yields centroid
sleep 2s

echo "STEP4: filling blank centroid rows..."
python fill2.py tmp-all-labeled centroid $nLines $nDimensions > tmp-centroid
cat tmp-centroid
\cp tmp-centroid centroid
sleep 4s

