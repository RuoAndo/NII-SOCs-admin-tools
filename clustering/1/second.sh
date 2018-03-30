# cluster size
#nClusters=2
#nDimensions=2
#nItems=2
#nThreads=1

# nItems=4 # nDimensions-2 / items: src dst n[* * * *]
#source ../parameter.txt
#source nThreads.txt

if [ "$1" = "" ]
then
    echo "argument required: ./second file nThreads nClusters"
    exit
fi

nThreads=$2
nDimensions=`head -n 1 $1 | awk -F ',' '{print NF}'`
nClusters=$3
nItems=`expr $nDimensions - 2`
nLines=`wc -l 0 | cut -d " " -f 1` 

echo "nLines:"$nLines
echo "nDimensions:"$nDimensions

cat count.cpp | sed "s/#define THREAD_NUM N/#define THREAD_NUM $nThreads/" > count.tmp.cpp
cat count.tmp.cpp | sed "s/#define CLUSTER_NUM N/#define CLUSTER_NUM $nClusters/" > count.tmp.2.cpp
cat count.tmp.2.cpp | sed "s/res.rightCols(N)/res.rightCols($nItems)/" > count.re.cpp
./build.sh count.re

cat avg.cpp | sed "s/#define THREAD_NUM N/#define THREAD_NUM $nThreads/" > avg.tmp.cpp
cat avg.tmp.cpp | sed "s/#define CLUSTER_NUM N/#define CLUSTER_NUM $nClusters/" > avg.tmp.2.cpp
cat avg.tmp.2.cpp | sed "s/#define ITEM_NUM N/#define ITEM_NUM $nItems/" > avg.tmp.3.cpp
cat avg.tmp.3.cpp | sed "s/rightCols(N)/rightCols($nItems)/" > avg.re.cpp
./build.sh avg.re

cat relabel.cpp | sed "s/#define THREAD_NUM N/#define THREAD_NUM $nThreads/" > relabel.tmp.cpp
cat relabel.tmp.cpp | sed "s/#define CLUSTER_NUM N/#define CLUSTER_NUM $nClusters/" > relabel.tmp.2.cpp
cat relabel.tmp.2.cpp | sed "s/rightCols(N)/rightCols($nItems)/" > relabel.re.cpp
./build.sh relabel.re

rm -rf diff-series
touch diff-series

COUNT=0
while [ $COUNT -lt 1000 ]; do    

   echo "STEP0: counting points per cluster..."

   ./count.re $nLines 1 | tee tmp-all-labeled 
   sleep 3s

   echo "STEP1: calculating centroid..." # input; 0, 0.lbl # output; centroid
   
   rm -rf centroid
   ./avg.re $nLines $nDimensions #yields centroid

   python fill.py centroid $1 | tee centroid-tmp

   sleep 2s

   cp centroid-tmp centroid

   echo "STEP2: relabeling ..." # input: 0, centroid # output: 0.rlbl

   ./relabel.re centroid $nClusters $nItems $nLines $nDimensions  

   diff=`python fill2.py 0.lbl 0.rlbl`
   echo "diff:"$diff"("${diff_bak}")"
   diff_bak="$diff"

   echo $diff >> diff-series
   
   
   \cp 0.rlbl 0.lbl
   #./build.sh count.re

   if [ $diff = 0 ]
      then
      break
   fi
      
   COUNT=`expr $COUNT + 1`
done

echo "done."
echo "iteration:"$COUNT
