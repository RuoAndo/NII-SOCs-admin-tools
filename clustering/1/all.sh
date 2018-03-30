if [ "$1" = "" ]
then
    echo "./all.sh file nThreads nClusters"
    fi

./first.sh $1 $2 $3
./second.sh $1 $2 $3
