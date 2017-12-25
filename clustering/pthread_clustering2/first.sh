# the number of clusters is hard-coded in *.cpp files.

# data seize: row:nLines, col:nDimensions

nLines=1000000
nDimensions=6
nThreads=2
nClusters=20

if [ "$1" = "" ]
then
    echo "argument required: ./first DATA_FILE_NAME"
    exit
fi

rm -rf process
rm -rf process2
rm -rf SSE

grep THREAD_NUM init-label.cpp | grep define
echo "the numbers of threads\:"$nThreads

# conversing init-label.cpp 
cat init-label.cpp | sed "s/#define THREAD_NUM 15/#define THREAD_NUM $nThreads/" > init-label.tmp.cpp
cat init-label.tmp.cpp | sed "s/#define CLUSTER_NUM 20/#define CLUSTER_NUM $nClusters/" > init-label.tmp.2.cpp
cat init-label.tmp.2.cpp | sed "s/res.rightCols(6)/res.rightCols($nDimensions)/" > init-label.re.cpp 

echo "STEP1: building executables ..."
./build.sh init-label.re

#./init-label.re $1

#./build.sh init-label
#./build.sh avg
#./build.sh relabel
#./build.sh fill2

#echo "STEP2: now spliting files ..".
#rm -rf hout*
#headLine=`expr $nLines \* $nThreads`

#head -n $headLine $1 > $1.headed
#split -l $nLines $1.headed hout

#pyenv local system

#ls hout* > list
#time ./rename.sh list

echo "STEP3: now initlializing labels ..."
time ./init-label.re $nLines $nDimensions

