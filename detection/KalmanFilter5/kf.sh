time python read-split.py $1 $2

ls *.spl > list-spl

rm -rf kf-all
touch kf-all

while read line; do
    fname=`wc -l $line | cut -d " " -f 2`
    ln=`wc -l $line | cut -d " " -f 1`
    ./main $fname $ln >> kf-all
done < list-spl
