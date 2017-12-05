pip install pandas
pip install numpy
pip install keras
pip install sklearn
pip install matplotlib
pip install tensorflow

rm -rf rnn_*

rm -rf rnn_all_in
touch rnn_all_in

rm -rf rnn_all_out
touch rnn_all_out

while read line; do
    echo $line
    rm -rf rnn_in_${line}
    python 20.py in_${line}_all instlist
    #cat rnn_in_${line} >> rnn_all_in
    cat rnn_${line} >> rnn_all_in
done < $1

./sort.pl rnn_all_in > tmp_in

while read line; do
    echo $line
    rm -rf rnn_out_${line}
    python 20.py out_${line}_all instlist
    #cat rnn_out_${line} >> rnn_all_out
    cat rnn_${line} >> rnn_all_out
done < $1

./sort.pl rnn_all_out > tmp_out




