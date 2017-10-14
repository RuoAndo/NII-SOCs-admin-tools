python cat-all.py csvlist-sorted > tmp
./sort-fp.pl tmp > tmp-sorted
python date-trans2.py tmp-sorted 2017 10 01 > tmp-sorted-dated
