#!/bin/sh

if [ "$1" = "" ]
then
    echo "no argument. ./a.out yyyy mm dd"
    exit
fi

# ls
# 1.py         20171004_30  20171010_30  3.py        csvlist-sorted   listup.pl        sort-csv.pl     warnlist
# 20171000_30  20171005_30  20171011_30  addWarn.py  date-trans.py    pa.sh            sort.pl
# 20171001_30  20171006_30  20171012_30  auto.sh     do.sh            rnn.pl           sort-rnn.pl
# 20171002_30  20171007_30  20.py        cat.sh      gen-warnlist.sh  rnn.py           trans-sort.py
# 20171003_30  20171008_30  2.py         csvlist     gen-wList.py     sort-csvlist.pl  

./listup.pl | grep HIBETSU > csvlist
python trans-sort.py csvlist 
ls *csv > csvlist
echo "sorting csvlist..."  
./sort-csvlist.pl csvlist > csvlist-sorted
echo "sorting warnlist..."  
python gen-wList.py csvlist-sorted > warnlist
echo "generating fp* files..."  
rm -rf fp-*; python 3.py warnlist csvlist-sorted > tmp
ls fp-* > fplist
time ./do.sh fplist
ls rnn_* > rnnlist
./cat.sh rnnlist
./sort-rnn.pl rnn-all > rnn-all-sorted
python addWarn.py warnlist rnn-all-sorted > rnn-all-sorted-warned
python date-trans.py rnn-all-sorted-warned $1 $2 $3 > rnn-all-sorted-warned-dated
