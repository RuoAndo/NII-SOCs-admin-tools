python 10.py tmp-sorted > tmp-list
./drem.pl tmp-list > tmp-list-drem
./grep.sh tmp-list-drem warnlist > warnlist-sorted
