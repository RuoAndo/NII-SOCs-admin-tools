if [ "$1" = "" ]
then
    echo "argument required: ./all.sh file nThreads nDimensions nClusters nItems"
    exit
fi

time ./first.sh $1 $2 $3 $4 $5
time ./second.sh $1 $2 $3 $4 $5
