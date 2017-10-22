nLines=1000000
<<<<<<< HEAD
nThreads=100
=======
nThreads=30

time ./build.sh group3
>>>>>>> cf9241e39533774b65747703f7ab38663b137243

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


