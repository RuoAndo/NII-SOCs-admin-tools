while read line; do
    python count.py $line
done < $1
