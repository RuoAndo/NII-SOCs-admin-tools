#cat list-abuseipdb | cut -d "," -f 1 > tmp-abuseipdb
cat $1 | cut -d "," -f 1 > tmp-abuseipdb

while read line; do
    # echo $line
    result=`geoiplookup -f GeoLiteCity.dat $line`
    echo ${line}","${result}
done < tmp-abuseipdb
