#three=`date --date '3 day ago' +%Y-%m-%d`
#echo $three
#lstm_in_labeled 

year=2018
month=01
day=16

grepdate=`date --date '4 day ago' +%Y-%m-%d` 
grepdate2=`date --date '5 day ago' +%Y-%m-%d` 

#recent=2

#wll=`wc -l list | cut -d " " -f 1`  
#echo $wll
#span1=`expr $wll \* 60 \* 24`
#echo $span1
#span2=`expr 1440 \* $recent`
#echo $span2
#span3=`expr $span1 - $span2`
#echo $span3

#exit

#if [ "$2" = "" ]
#then
#    echo "no argument: time ./auto.sh FILENAME 2017 10 15"
#    exit
#fi

pyenv local 3.4.7

while read line; do
    echo $line
    python 21.py "in_"$line"_all" in #> lstm_"$line"_in
done < $1

rm -rf lstm_in_all; touch lstm_in_all

while read line; do
    cat "lstm_"$line"_in" >> lstm_in_all
done < $1

./sort-lstm.pl lstm_in_all > lstm_in_all_sorted 
python date-trans-2.py lstm_in_all_sorted $year $month $day instlist > lstm_in_labeled
#python date-trans-3.py lstm_in_all_sorted $year $month $day instlist $span3 > lstm_in_labeled_recent

grep $grepdate lstm_in_labeled > lstm_in_labeled_tmp
grep $grepdate2 lstm_in_labeled >> lstm_in_labeled_tmp
./sort-recent.pl lstm_in_labeled_tmp > lstm_in_labeled_recent

#########################################

while read line; do
    echo $line
    python 21.py "out_"$line"_all" out #> lstm_"$line"_out  
done < $1

rm -rf lstm_out_all; touch lstm_out_all

while read line; do
    cat "lstm_"$line"_out" >> lstm_out_all
done < $1

./sort-lstm.pl lstm_out_all > lstm_out_all_sorted 
python date-trans-2.py lstm_out_all_sorted $year $month $day instlist > lstm_out_labeled
#python date-trans-3.py lstm_out_all_sorted $year $month $day instlist $span3 > lstm_out_labeled_recent

grep $grepdate lstm_out_labeled > lstm_out_labeled_tmp
grep $grepdate2 lstm_out_labeled >> lstm_out_labeled_tmp
./sort-recent.pl lstm_out_labeled_tmp > lstm_out_labeled_recent
