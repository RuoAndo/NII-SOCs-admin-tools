if [ "$1" = "" ]
then
    echo "no argument: ./auto.sh instIDlist epoch 2017 10 15" 
    exit
fi

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
    python 20.py in_${line}_all instlist $2
    #cat rnn_in_${line} >> rnn_all_in

    python date-trans-2.py in_${line}_all $3 $4 $5 > in_${line}_all_dated
    python date-trans-2.py rnn_in_${line} $3 $4 $5 > kf_in_${line}_dated

    cat rnn_${line} >> rnn_all_in
done < $1

./sort.pl rnn_all_in > tmp_in
python date-trans-2.py tmp_in $2 $3 $4 > tmp_in_dated

while read line; do
    echo $line
    rm -rf rnn_out_${line}
    python 20.py out_${line}_all instlist $2
    #cat rnn_out_${line} >> rnn_all_out

    python date-trans-2.py out_${line}_all $3 $4 $5 > out_${line}_all_dated

    python date-trans-2.py rnn_out_${line} $3 $4 $5 > rnn_out_${line}_dated


    cat rnn_${line} >> rnn_all_out
done < $1

./sort.pl rnn_all_out > tmp_out
python date-trans-2.py tmp_out $3 $4 $5 > tmp_out_dated



