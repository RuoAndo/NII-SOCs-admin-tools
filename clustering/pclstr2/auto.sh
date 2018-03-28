if [ "$1" = "" ]
then
    echo "./auto.sh nThread nDimensions nClusters nItems"
    exit
fi

date=`date --date '2 day ago' +%Y%m%d`
echo $date

time ./first.sh all-${date} $1 $2 $3
time ./second.sh all-${date} $1 $2 $3 $4 
