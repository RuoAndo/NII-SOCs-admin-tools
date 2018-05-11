while read line; do
    g=`geoiplookup $line`
    echo $line":"$g
done < $1
