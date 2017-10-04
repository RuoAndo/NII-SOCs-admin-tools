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
python date-trans.py rnn-all-sorted-warned 2017 09 20 > rnn-all-sorted-warned-dated
