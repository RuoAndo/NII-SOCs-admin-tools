rm -rf rnn-all
touch rnn-all

while read line; do
    cat $line >> rnn-all
done < $1
