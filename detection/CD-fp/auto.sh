#!/bin/sh

if [ "$1" = "" ]
then
    echo "no argument. ./a.out yyyy mm dd"
fi

ls *csv > csvlist
./sort-csv.pl csvlist> csvlist-sorted
python gen-wList.py csvlist-sorted > warnlist
rm -rf fp-*; python 3.py warnlist csvlist-sorted > tmp
ls fp-* > fplist
time ./do.sh fplist
ls rnn_* > rnnlist
./cat.sh rnnlist
./sort-rnn.pl rnn-all > rnn-all-sorted
python addWarn.py warnlist rnn-all-sorted > rnn-all-sorted-warned
python date-trans.py rnn-all-sorted-warned $1 $2 $3 > rnn-all-sorted-warned-dated
