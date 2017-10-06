if [ "$1" = "" ]
then
    echo "no argument: ./auto.sh yyyy mm dd"
    exit
fi

ls *csv > csvlist
./sort-csv.pl csvlist> csvlist-sorted
python gen-wList.py csvlist-sorted > warnlist
rm -rf pa-*; python 3.py warnlist csvlist-sorted > tmp
ls pa-* > palist
time ./do.sh palist
ls rnn_* > rnnlist
./cat.sh rnnlist
./sort-rnn.pl rnn-all > rnn-all-sorted
python addWarn.py warnlist rnn-all-sorted > rnn-all-sorted-warned
python date-trans.py rnn-all-sorted-warned $1 $2 $3 > rnn-all-sorted-warned-dated
