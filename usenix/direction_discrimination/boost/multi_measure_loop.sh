for ((i=2 ; i<12 ; i++))
do
    echo $i
    str="date -d '"${i}" day ago' "+%Y%m%d""
    echo $str
    date=`eval $str`
    echo $date
    ./multi_measure_3.sh $1 $date
done

