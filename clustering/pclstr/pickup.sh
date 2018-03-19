if [ "$1" = "" ]
then
    echo "argument required: ./pickup.sh clusterNo"
    exit
fi

rm -rf tmp-grep
touch tmp-grep


echo "processing chunk 0..."
grep -n $1 0.lbl >> tmp-grep


rm -rf tmp-reverse
touch tmp-reverse

while read line; do
    l=`echo $line | cut -d ":" -f 1`
    #echo $l
    nCls=`expr $l + 1` 
    sed -n ${nCls}p 0 >> tmp-reverse
done < tmp-grep

python reverse.py tmp-reverse

