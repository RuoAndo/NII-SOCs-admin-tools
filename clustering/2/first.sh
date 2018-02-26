# the number of clusters is hard-coded in *.cpp files.
# data seize: row:nLines, col:nDimensions

#nLines=1000
#nThreads=3
#nDimensions=2
#nClusters=3

source parameter.txt

allLine=`expr $nLines \* $nThreads`

if [ "$1" = "" ]
then
    echo "argument required: ./first DATA_FILE_NAME"
    exit
fi

echo "the numbers of threads\:"$nThreads

# conversing init-label.cpp 
cat init-label.cpp | sed "s/#define THREAD_NUM N/#define THREAD_NUM $nThreads/" > init-label.tmp.cpp
cat init-label.tmp.cpp | sed "s/#define CLUSTER_NUM N/#define CLUSTER_NUM $nClusters/" > init-label.tmp.2.cpp
cat init-label.tmp.2.cpp | sed "s/rightCols(N)/rightCols($nDimensions)/" > init-label.re.cpp 

echo "STEP1: building executables ..."
./build.sh init-label.re

echo "STEP2: spliting files ..".
rm -rf hout*
head -n $allLine $1 > $1.headed
split -l $nLines $1.headed hout

ls hout* > list
time ./rename.sh list

echo "STEP3: now initlializing labels ..."
time ./init-label.re $nLines $nDimensions

\cp count-start count-now
rm -rf SSE
