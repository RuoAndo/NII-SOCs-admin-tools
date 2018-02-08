# first.sh
# input file: 0 (nDimensions * nLines)
# output file: 0.lbl

nDimensions=2
nThreads=1
nClusters=2

if [ "$1" = "" ]
then
    echo "argument required: ./first 0"
    exit
fi

rm init-label.re.cpp

cat init-label.cpp | sed "s/#define THREAD_NUM N/#define THREAD_NUM $nThreads/" > init-label.tmp.cpp
cat init-label.tmp.cpp | sed "s/#define CLUSTER_NUM N/#define CLUSTER_NUM $nClusters/" > init-label.tmp.2.cpp
cat init-label.tmp.2.cpp | sed "s/leftCols(N)/leftCols($nDimensions)/" > init-label.re.cpp

./build.sh init-label.re

nLines=`wc -l 0 | cut -d " " -f 1` 
echo $nLines
time ./init-label.re $nLines $nDimensions
