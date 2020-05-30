ls AWS*xml > list

while read line; do
    #echo $line
    python 1-1.py $line
done < list
