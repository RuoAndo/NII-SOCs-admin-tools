rm -rf kf_*

rm -rf kf_all_in
touch kf_all_in

rm -rf kf_all_out
touch kf_all_out

pyenv local system

while read line; do
    echo $line
    rm -rf kf_in_${line}
    #python kf2.py in_${line}_all instlist
    python kf4.py in_${line}_all instlist
    cat kf_in_${line} >> kf_all_in
done < $1

./sort.pl kf_all_in > tmp_in

# output: timeslot, score,     ID,   name
#              17, 0.00717402,XXXX, YYYY

while read line; do
    echo $line
    rm -rf kf_out_${line}
    python kf4.py out_${line}_all instlist
    cat kf_out_${line} >> kf_all_out
done < $1

./sort.pl kf_all_out > tmp_out

