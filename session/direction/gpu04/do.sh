ls x* > list

rm -rf rendered-all
touch rendered-all

while read line; do
    echo $line
    rm -rf rendered_$line
    nLines_to_process=`wc -l $line | cut -d " " -f 1`
    ./netmask5 monitoring_list2 $nLines_to_process &
    #cat rendered_$line >> rendered-all
done < list

wait

while read line; do
    echo $line
    #rm -rf rendered_$line
    #./netmask5 monitoring_list2 $line 1000
    cat rendered_$line >> rendered-all
done < list
