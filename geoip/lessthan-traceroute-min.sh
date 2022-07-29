cat MIN-TRACEROUTE-COMP  | awk -F',' '$4<$8 {print}' > tmp

while read line; do

    echo $line
    #ip=`echo $line | cut -d "," -f 3`
    #geoiplookup $ip 

done < tmp
