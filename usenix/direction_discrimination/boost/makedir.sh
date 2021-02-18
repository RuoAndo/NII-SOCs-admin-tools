wget https://ip-ranges.amazonaws.com/ip-ranges.json

rm -rf list-*

cat ip-ranges.json | jq ".prefixes[].region" | uniq | sed s/\"//g > list-region-tmp
./drem.pl list-region-tmp > list-region

while read line; do
    echo $line

    #cat ip-ranges.json | jq '.prefixes[] | select(.region == "eu-west-1") | .ip_prefix' | sed s/\"//g | sed s/\\//,/g
    comstr=`echo "cat ip-ranges.json | jq '.prefixes[] | select(.region == \"${line}\") | .ip_prefix' | sed s/\\\\\"//g | sed s/\\\\\\\//,/g"` 
    echo $comstr
    mkdir $line
    #eval $comstr > list-${line}
done < list-region

