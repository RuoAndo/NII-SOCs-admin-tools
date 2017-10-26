if [ "$1" = "" ]
then
    echo "argument required: ./pickup.sh clusterNo"
    exit
fi

grep -n $1 0.lbl > tmp-grep

while read line; do
    l=`echo $line | cut -d ":" -f 1`
    #echo $l
    sed -n ${l}p 0
done < tmp-grep

