nDimensions=6

if [ "$1" = "" ]
then
    echo "argument required: ./first DATA_FILE_NAME"
    exit
fi

./build.sh init-label
./build.sh count
./build.sh avg
./build.sh relabel
./build.sh fill2
./build.sh pickup2

python trans.py $1 > 0

nLines=`wc -l 0 | cut -d " " -f 1` 
echo $nLines
time ./init-label $nLines $nDimensions
