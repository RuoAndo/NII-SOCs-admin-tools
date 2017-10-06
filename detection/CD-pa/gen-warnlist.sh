ls *csv > csvlist
./sort-csv.pl csvlist> csvlist-sorted
python gen-wList.py csvlist-sorted > warnlist

