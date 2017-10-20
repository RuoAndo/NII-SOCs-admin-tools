nLines=1000000
nThreads=300

if [ "$1" = "" ]
then
    echo "argument required: ./first DATA_FILE_NAME"
    exit
fi

rm -rf hout*
headLine=`expr $nLines \* $nThreads` 
head -n $headLine $1 > $1.headed

split -l $nLines $1.headed hout
ls hout* > list
#time ./rename.sh list
time ./cp.sh list


