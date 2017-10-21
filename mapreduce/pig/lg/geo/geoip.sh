while read line; do
    # echo $line
    geoiplookup -f GeoLiteCity.dat $line
done < $1
