year=2018
month=01
day=16

grepdate=`date --date '4 day ago' +%Y-%m-%d` 
grepdate2=`date --date '5 day ago' +%Y-%m-%d` 

#rm -rf lstm_in_all; touch lstm_in_all

#while read line; do
#    cat "lstm_"$line"_in" >> lstm_in_all
#done < $1

#./sort-lstm.pl lstm_in_all > lstm_in_all_sorted 
#python date-trans-2.py lstm_in_all_sorted $year $month $day instlist > lstm_in_labeled
#python date-trans-3.py lstm_in_all_sorted $year $month $day instlist $span3 > lstm_in_labeled_recent

grep $grepdate lstm_in_labeled > lstm_in_labeled_tmp
grep $grepdate2 lstm_in_labeled >> lstm_in_labeled_tmp
./sort-recent.pl lstm_in_labeled_tmp > lstm_in_labeled_recent

#while read line; do
#    cat "lstm_"$line"_out" >> lstm_out_all
#done < $1

#./sort-lstm.pl lstm_out_all > lstm_out_all_sorted 
#python date-trans-2.py lstm_out_all_sorted $year $month $day instlist > lstm_out_labeled
#python date-trans-3.py lstm_out_all_sorted $year $month $day instlist $span3 > lstm_out_labeled_recent

grep $grepdate lstm_out_labeled > lstm_out_labeled_recent
./sort-recent.pl lstm_out_labeled_tmp > lstm_out_labeled_recent
