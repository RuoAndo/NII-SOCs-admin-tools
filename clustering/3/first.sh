# the number of clusters is hard-coded in *.cpp files.
# data seize: row:nLines, col:nDimensions

#nLines=`wc -l $1`
#nLines=1000
#echo "nLines:"$nLines

nLines=6000
nThreads=5
nDimensions=8
nClusters=10

#source ../parameter.txt
#\cp ../tmp tmp

allLine=`expr $nLines \* $nThreads`

#if [ "$1" = "" ]
#then
#    echo "argument required: ./first DATA_FILE_NAME"
#    exit
#fi

echo "the numbers of threads\:"$nThreads

echo "STEP1: building executables ..."

# conversing init-label.cpp 
cat init-label.cpp | sed "s/#define THREAD_NUM N/#define THREAD_NUM $nThreads/" > init-label.tmp.cpp
cat init-label.tmp.cpp | sed "s/#define CLUSTER_NUM N/#define CLUSTER_NUM $nClusters/" > init-label.tmp.2.cpp
cat init-label.tmp.2.cpp | sed "s/rightCols(N)/rightCols($nDimensions)/" > init-label.re.cpp 

./build.sh init-label.re

    #\cp count-now count-previous
cat count.cpp | sed "s/#define THREAD_NUM N/#define THREAD_NUM $nThreads/" > count.tmp.cpp
cat count.tmp.cpp | sed "s/#define CLUSTER_NUM N/#define CLUSTER_NUM $nClusters/" > count.re.cpp
    #cat count.tmp.2.cpp | sed "s/rightCols(N)/rightCols($nDimensions)/" > count.re.cpp 
./build.sh count.re 

#cat avg.cpp | sed "s/#define THREAD_NUM N/#define THREAD_NUM $nThreads/" > avg.tmp.cpp
#cat avg.tmp.cpp | sed "s/#define CLUSTER_NUM N/#define CLUSTER_NUM $nClusters/" > avg.tmp.2.cpp
#cat avg.tmp.2.cpp | sed "s/#define ITEM_NUM N/#define ITEM_NUM $nItems/" > avg.tmp.3.cpp
#cat avg.tmp.3.cpp | sed "s/rightCols(N)/rightCols($nDimensions)/" > avg.re.cpp 
#./build.sh avg.re

#cat relabel.cpp | sed "s/#define THREAD_NUM N/#define THREAD_NUM $nThreads/" > relabel.tmp.cpp
#cat relabel.tmp.cpp | sed "s/#define CLUSTER_NUM N/#define CLUSTER_NUM $nClusters/" > relabel.tmp.2.cpp
#cat relabel.tmp.2.cpp | sed "s/rightCols(N)/rightCols($nDimensions)/" > relabel.re.cpp 
#./build.sh relabel.re
    
echo "STEP2: spliting files ..".
rm -rf hout*

head -n $allLine $1 > $1.headed
split -l $nLines $1.headed hout

#head -n $allLine tmp > tmp.headed
#split -l $nLines tmp.headed hout

ls hout* > list
time ./rename.sh list

echo "STEP3: now initlializing labels ..."
time ./init-label.re $nLines $nDimensions

# \cp count-start count-now
# rm -rf SSE
