ls x* > list

rm -rf rendered-all
touch rendered-all

while read line; do
    echo $line
    rm -rf rendered_$line
    ./netmask5 monitoring_list2 $line 1000 &
    #cat rendered_$line >> rendered-all
done < list

wait

while read line; do
    echo $line
    #rm -rf rendered_$line
    #./netmask5 monitoring_list2 $line 1000
    cat rendered_$line >> rendered-all
done < list
