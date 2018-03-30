# first.sh
# input file: 0 (nDimensions * nLines)
# output file: 0.lbl

if [ "$3" = "" ]
then
    echo "argument required: ./first file nThreads nClusters"
    exit
fi

\cp $1 0

nThreads=$2
nDimensions=`head -n 1 $1 | awk -F ',' '{print NF}'`
nClusters=$3
nItems=`expr $nDimensions - 2`

echo "nItems:"$nItems
sleep 2s

rm init-label.re.cpp

cat init-label.cpp | sed "s/#define THREAD_NUM N/#define THREAD_NUM $nThreads/" > init-label.tmp.cpp
cat init-label.tmp.cpp | sed "s/#define CLUSTER_NUM N/#define CLUSTER_NUM $nClusters/" > init-label.tmp.2.cpp
cat init-label.tmp.2.cpp | sed "s/leftCols(N)/leftCols($nDimensions)/" > init-label.re.cpp

./build.sh init-label.re

cat count.cpp | sed "s/#define THREAD_NUM N/#define THREAD_NUM $nThreads/" > count.tmp.cpp
cat count.tmp.cpp | sed "s/#define CLUSTER_NUM N/#define CLUSTER_NUM $nClusters/" > count.tmp.2.cpp
cat count.tmp.2.cpp | sed "s/res.rightCols(N)/res.rightCols($nDimensions)/" > count.re.cpp
./build.sh count.re

cat avg.cpp | sed "s/#define THREAD_NUM N/#define THREAD_NUM $nThreads/" > avg.tmp.cpp
cat avg.tmp.cpp | sed "s/#define CLUSTER_NUM N/#define CLUSTER_NUM $nClusters/" > avg.tmp.2.cpp
cat avg.tmp.2.cpp | sed "s/#define ITEM_NUM N/#define ITEM_NUM $nItems/" > avg.tmp.3.cpp
cat avg.tmp.3.cpp | sed "s/rightCols(N)/rightCols($nDimensions)/" > avg.re.cpp
./build.sh avg.re

cat relabel.cpp | sed "s/#define THREAD_NUM N/#define THREAD_NUM $nThreads/" > relabel.tmp.cpp
cat relabel.tmp.cpp | sed "s/#define CLUSTER_NUM N/#define CLUSTER_NUM $nClusters/" > relabel.tmp.2.cpp
cat relabel.tmp.2.cpp | sed "s/rightCols(N)/rightCols($nDimensions)/" > relabel.re.cpp
./build.sh relabel.re

nLines=`wc -l 0 | cut -d " " -f 1` 
echo $nLines
time ./init-label.re $nLines $nDimensions
