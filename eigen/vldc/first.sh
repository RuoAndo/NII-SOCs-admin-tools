# the number of clusters is hard-coded in *.cpp files.

# row:nLines, col:nItems
nLines=500000
nItems=5

if [ "$1" = "" ]
then
    echo "argument required: ./first FILE_NAME"
    exit
fi

echo "building executables ..."
./build.sh rand-labeling
./build.sh avg
./build.sh relabel

echo "now initlializing labels ..".
split -l $LN $1 out
ls out* > list
time ./rename.sh list

echo "now initlializing labels ..."
# data size is nLines * nItems (eg. 500000 * 5)
time ./rand-labeling $nLines $Nitems

