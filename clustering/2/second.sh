nLines=1000
nThreads=2
allLine=`expr $nLines \* $nThreads`

nDimensions=2
nItems=2 # nDimensions-2 / items: src dst n[* * *] 

nClusters=3

echo "concatenating all labeled files ..." 
ls *.lbl > 0
sleep 2s

echo "STEP: counting points per cluster..."
cat count.cpp | sed "s/#define THREAD_NUM N/#define THREAD_NUM $nThreads/" > count.tmp.cpp
cat count.tmp.cpp | sed "s/#define CLUSTER_NUM N/#define CLUSTER_NUM $nClusters/" > count.re.cpp
#cat count.tmp.2.cpp | sed "s/rightCols(N)/rightCols($nDimensions)/" > count.re.cpp 
./build.sh count.re 
./count.re $nLines 1

echo "STEP: calculating centroid..." 
cat avg.cpp | sed "s/#define THREAD_NUM N/#define THREAD_NUM $nThreads/" > avg.tmp.cpp
cat avg.tmp.cpp | sed "s/#define CLUSTER_NUM N/#define CLUSTER_NUM $nClusters/" > avg.tmp.2.cpp
cat avg.tmp.2.cpp | sed "s/#define ITEM_NUM N/#define ITEM_NUM $nItems/" > avg.tmp.3.cpp
cat avg.tmp.3.cpp | sed "s/rightCols(N)/rightCols($nDimensions)/" > avg.re.cpp 
./build.sh avg.re
rm -rf centroid
time ./avg.re $nLines $nDimensions #yields centroid
sleep 2s
