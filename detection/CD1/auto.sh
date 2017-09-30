rm -rf rnn-all
touch rnn-all
rm -rf rnn_*

while read line; do
    echo $line
    rm -rf rnn_in_${line}
    python 20.py in_${line}_all instlist
    cat rnn_in_${line} >> rnn_all
done < $1

./sort.pl rnn_all > tmp




