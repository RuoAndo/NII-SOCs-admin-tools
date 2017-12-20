while read line; do
    #echo $line
    g=`geoiplookup $line`
    echo $line","$g
done < $1
