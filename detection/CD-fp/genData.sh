#!/bin/sh

./listup.pl | grep HIBETSU > csvlist
python trans-sort.py csvlist 
#ls *csv > csvlist
echo "sorting csvlist..."  
./sort-csvlist.pl csvlist > csvlist-sorted
echo "sorting warnlist..."  
python gen-wList.py csvlist-sorted > warnlist
echo "generating fp* files..."  
rm -rf fp-*; python 3.py warnlist csvlist-sorted > tmp
ls fp-* > fplist
#time ./do.sh fplist
