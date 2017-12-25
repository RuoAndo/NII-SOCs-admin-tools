if [ "$1" = "" ]
then
    echo "argument required: ./pickup.sh clusterNo"
    exit
fi

grep -n $1 all-relabeled > tmp-grep

rm -rf tmp-reverse
touch tmp-reverse

while read line; do
    l=`echo $line | cut -d ":" -f 1`
    #echo $l
    nCls=`expr $l + 1` 
    sed -n ${nCls}p all >> tmp-reverse
done < tmp-grep

python reverse.py tmp-reverse

