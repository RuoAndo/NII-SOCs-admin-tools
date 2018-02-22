nLines=1000
nThreads=3
allLine=`expr $nLines \* $nThreads`

nDimensions=2
nItems=2 # nDimensions-2 / items: src dst n[* * *] 

nClusters=3

echo "concatenating all labeled files ..." 
ls *.lbl > list-lbl
./sort.pl list-lbl > list-lbl-sorted
./cat.sh list-lbl-sorted > list-lbl-tmp

sleep 2s

echo "STEP: counting points per cluster..."
\cp count-now count-previous
cat count.cpp | sed "s/#define THREAD_NUM N/#define THREAD_NUM $nThreads/" > count.tmp.cpp
cat count.tmp.cpp | sed "s/#define CLUSTER_NUM N/#define CLUSTER_NUM $nClusters/" > count.re.cpp
#cat count.tmp.2.cpp | sed "s/rightCols(N)/rightCols($nDimensions)/" > count.re.cpp 
./build.sh count.re 
./count.re $nLines 1 | tee count-now


echo "STEP: calculating centroid..." 
cat avg.cpp | sed "s/#define THREAD_NUM N/#define THREAD_NUM $nThreads/" > avg.tmp.cpp
cat avg.tmp.cpp | sed "s/#define CLUSTER_NUM N/#define CLUSTER_NUM $nClusters/" > avg.tmp.2.cpp
cat avg.tmp.2.cpp | sed "s/#define ITEM_NUM N/#define ITEM_NUM $nItems/" > avg.tmp.3.cpp
cat avg.tmp.3.cpp | sed "s/rightCols(N)/rightCols($nDimensions)/" > avg.re.cpp 
./build.sh avg.re
rm -rf centroid
time ./avg.re $nLines $nDimensions #yields centroid
sleep 2s

echo "STEP: relabeling ..."

cat relabel.cpp | sed "s/#define THREAD_NUM N/#define THREAD_NUM $nThreads/" > relabel.tmp.cpp
cat relabel.tmp.cpp | sed "s/#define CLUSTER_NUM N/#define CLUSTER_NUM $nClusters/" > relabel.tmp.2.cpp
cat relabel.tmp.2.cpp | sed "s/rightCols(N)/rightCols($nDimensions)/" > relabel.re.cpp 
./build.sh relabel.re
sleep 2s

time ./relabel.re centroid $nClusters $nItems $nLines $nDimensions
ls *.rlbl > list-rlbl
./sort.pl list-rlbl > list-rlbl-sorted
./cat.sh list-rlbl-sorted > list-rlbl-tmp

echo "converting *.rlbl to *.lbl..."
time ./rename2.sh list-rlbl

python sse.py centroid count-now count-previous
