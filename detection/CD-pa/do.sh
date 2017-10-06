while read line; do
    echo $line
    time python rnn.py $line
done < $1
