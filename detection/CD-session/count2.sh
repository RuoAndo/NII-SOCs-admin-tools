while read line; do
    python count2.py $line
done < $1
