for line in `cat ${1}`
do
    ./iostat.sh $line > $line &
done
