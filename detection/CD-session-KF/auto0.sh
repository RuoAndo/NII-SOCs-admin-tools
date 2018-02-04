date8=`date --date '8 day ago' +%Y%m%d`
date1=`date --date '1 day ago' +%Y%m%d`

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
python date-trans-2.py lstm_in_all_sorted 2018 02 01 instlist > lstm_in_labeled

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
python date-trans-2.py lstm_out_all_sorted 2018 02 01 instlist > lstm_out_labeled

