# the number of clusters is hard-coded in *.cpp files.

# data seize: row:nLines, col:nDimensions
nLines=500000
nDimensions=5

nThreads=10

if [ "$1" = "" ]
then
    echo "argument required: ./first DATA_FILE_NAME"
    exit
fi

echo "STEP1: building executables ..."
./build.sh init-label
./build.sh avg
./build.sh relabel
./build.sh fill2

echo "STEP2: now spliting files ..".

headLine=`expr $nLines \* $nThreads` 
head -n $headLine $1 > $1.headed

split -l $nLines $1.headed hout
ls hout* > list
time ./rename.sh list

echo "STEP3: now initlializing labels ..."
time ./init-label $nLines $nDimensions

