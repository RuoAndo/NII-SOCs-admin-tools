nDimensions=6
nThreads=1
nClusters=3    

if [ "$1" = "" ]
then
    echo "argument required: ./first DATA_FILE_NAME"
    exit
fi

cat init-label.cpp | sed "s/#define THREAD_NUM N/#define THREAD_NUM $nThreads/" > init-label.tmp.cpp
cat init-label.tmp.cpp | sed "s/#define CLUSTER_NUM N/#define CLUSTER_NUM $nClusters/" > init-label.re.cpp
#cat init-label.tmp.2.cpp | sed "s/res.rightCols(6)/res.rightCols($nDimensions)/" > init-label.re.cpp 

./build.sh init-label.re

nLines=`wc -l 0 | cut -d " " -f 1` 
echo $nLines
time ./init-label.re $nLines $nDimensions
