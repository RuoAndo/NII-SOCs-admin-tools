while read line; do
    echo $line
    python slmbr.py $line
    sleep 1s
done < $1
