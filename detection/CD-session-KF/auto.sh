rm -rf rnn_*

rm -rf rnn_all_in
touch rnn_all_in

rm -rf rnn_all_out
touch rnn_all_out

while read line; do
    echo $line
    rm -rf rnn_in_${line}
    python kf2.py in_${line}_all instlist
    cat rnn_in_${line} >> rnn_all_in
done < $1

./sort.pl rnn_all_in > tmp_in

# output: timeslot, score,     ID,   name
#              17, 0.00717402,XXXX, YYYY

while read line; do
    echo $line
    rm -rf rnn_out_${line}
    python kf2.py out_${line}_all instlist
    cat rnn_out_${line} >> rnn_all_out
done < $1

./sort.pl rnn_all_out > tmp_out




