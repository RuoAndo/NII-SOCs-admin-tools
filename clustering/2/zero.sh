if [ "$1" = "" ]
then
    echo "argument required: ./zero file nLinesToSplit"
    exit
fi

fname=$1
nLines=$2

split -l $nLines $fname -d -a 6

allnLines=`wc -l $1 | cut -d " " -f 1`
echo $allnLines
nThreads=`expr $allnLines / $2`
echo "nThreads:"$nThreads

cat group8.cpp | sed "s/#define THREAD_NUM N/#define THREAD_NUM $nThreads/" > group8.re.cpp

./build.sh group8.re
./group8.re
