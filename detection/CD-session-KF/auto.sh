date8=`date --date '8 day ago' +%Y%m%d`
date1=`date --date '1 day ago' +%Y%m%d`

if [ "$2" = "" ]
then
    echo "no argument: time ./auto.sh FILENAME 2017 10 15"
    exit
fi

rm -rf kf_*

rm -rf kf_all_in
touch kf_all_in

rm -rf kf_all_out
touch kf_all_out

pyenv local system

while read line; do
    echo $line
    rm -rf kf_in_${line}
    python kf2.py in_${line}_all instlist
    #python kf6.py in_${line}_all instlist

    #python date-trans-2.py in_${line}_all $2 $3 $4 > in_${line}_all_dated
    python date-trans-2.py kf_in_${line} $2 $3 $4 > kf_in_${line}_dated
    
    \cp kf_in_${line}_dated kf_in_${line}_${date8}_${date1}

    cat kf_in_${line} >> kf_all_in_${date8}_${date1}
done < $1

./sort.pl kf_all_in > tmp_in
python date-trans-2.py tmp_in $2 $3 $4 > tmp_in_dated_${date8}_${date1}

# output: timeslot, score,     ID,   name
#              17, 0.00717402,XXXX, YYYY

while read line; do
    echo $line
    rm -rf kf_out_${line}
    #python kf6.py out_${line}_all instlist
    python kf2.py out_${line}_all instlist

    #python date-trans-2.py out_${line}_all $2 $3 $4 > out_${line}_all_dated

    python date-trans-2.py kf_out_${line} $2 $3 $4 > kf_out_${line}_dated

    \cp kf_out_${line}_dated kf_out_${line}_dated_${date8}_${date1}

    cat kf_out_${line} >> kf_all_out_${date8}_${date1}
done < $1

./sort.pl kf_all_out > tmp_out
python date-trans-2.py tmp_out $2 $3 $4 > tmp_out_dated_${date8}_${date1}
