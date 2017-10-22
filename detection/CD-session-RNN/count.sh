while read line; do
    python count.py $line $2
done < $1
