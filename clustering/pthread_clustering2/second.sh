nLines=1000000
nDimensions=6
nThreads=66
nClusters=20
nItems=4 # nDimensions-2 / items: src dst n[* * *] 

echo "STEP0: building executables ..."
#./build.sh init-label
#./build.sh avg
#./build.sh relabel
#./build.sh fill2
#./build.sh count
#./build.sh pickup2

echo "STEP1: [REDUCE] concatenating label files ..." 
ls *.lbl > label_file_list
./sort.pl label_file_list > label_file_list_sorted
head -n $nThreads label_file_list_sorted > label_file_list.h
# reduce
rm -rf all-labeled
touch all-labeled
# yields all-labeled: cat $line >> all-labeled  
./cat-labeled.sh label_file_list.h 
wc -l all-labeled # could be size of all data
sleep 2s

echo "STEP2: counting points per cluster..."
# conversing count.cpp 
cat count.cpp | sed "s/#define THREAD_NUM 15/#define THREAD_NUM $nThreads/" > count.tmp.cpp
cat count.tmp.cpp | sed "s/#define CLUSTER_NUM 20/#define CLUSTER_NUM $nClusters/" > count.tmp.2.cpp
cat count.tmp.2.cpp | sed "s/res.rightCols(6)/res.rightCols($nDimensions)/" > count.re.cpp 
./build.sh count.re

# reading *.lbl ( 1* nLines)
time ./count.re $nLines 1 | tee tmp-all-labeled 
sleep 2s

echo "STEP3: calculating centroid..."
# conversing avg.cpp 
cat avg.cpp | sed "s/#define THREAD_NUM CONST/#define THREAD_NUM $nThreads/" > avg.tmp.cpp
cat avg.tmp.cpp | sed "s/#define CLUSTER_NUM CONST/#define CLUSTER_NUM $nClusters/" > avg.tmp.2.cpp
cat avg.tmp.2.cpp | sed "s/#define ITEM_NUM CONST/#define ITEM_NUM $nItems/" > avg.re.cpp
./build.sh avg.re
rm -rf centroid
time ./avg.re $nLines $nDimensions #yields centroid
sleep 2s

echo "STEP4: filling blank centroid rows..."
cat fill2.cpp | sed "s/#define THREAD_NUM CONST/#define THREAD_NUM $nThreads/" > fill2.tmp.cpp
cat fill2.tmp.cpp | sed "s/#define CLUSTER_NUM CONST/#define CLUSTER_NUM $nClusters/" > fill2.tmp.2.cpp
cat fill2.tmp.2.cpp | sed "s/#define ITEM_NUM CONST/#define ITEM_NUM $nItems/" > fill2.tmp.3.cpp
cat fill2.tmp.3.cpp | sed "s/ avg(CONST);/ avg($nItems);/" > fill2.re.cpp
./build.sh fill2.re

python fill2.py tmp-all-labeled centroid $nLines $nDimensions > tmp-centroid
cat tmp-centroid
\cp tmp-centroid centroid
sleep 4s

echo "STEP5: relabeling ..."

cat relabel.cpp | sed "s/#define THREAD_NUM CONST/#define THREAD_NUM $nThreads/" > relabel.tmp.cpp
cat relabel.tmp.cpp | sed "s/#define CLUSTER_NUM CONST/#define CLUSTER_NUM $nClusters/" > relabel.re.cpp
./build.sh relabel.re
time ./relabel.re centroid $nClusters $nItems $nLines $nDimensions 

echo "STEP6: [reduce] concatenating relabel files ..."
time ls *.rlbl > list-relabeled
./sort.pl list-relabeled > list-relabeled-sorted
head -n $nThreads list-relabeled-sorted > list-relabeled.h
time ./cat-relabeled.sh list-relabeled.h # yields all-relabeled
wc -l all-relabeled # could be size of all data
sleep 2s

echo "STEP8: converting *.labeled to *.relabeled..."
# \cp $COUNTER.rlbl $COUNTER.lbl 
time ./rename2.sh list-relabeled.h # from STEP6

echo "STEP7: counting points per cluster..."
time ./count.re $nLines 1 | tee tmp-all-relabeled 
sleep 2s

# comparing STEP2 with STEP7
echo "STEP7: calculating SSE..."
time python sse.py centroid tmp-all-relabeled tmp-all-labeled
cat SSE
sleep 2s

#./build.sh pickup2; ./pickup2 centroid $nClusters $nItems $nLines $nDimensions | tee tmp
#python reverse.py tmp
