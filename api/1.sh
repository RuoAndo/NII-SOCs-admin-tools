
COUNT=0

while read line; do
    if [ $COUNT -gt 0 ] ; then

	ip=`echo $line | cut -d "," -f 1`
	ipadr=`echo $ip | sed -e 's/\"//g'`

	curlr=`curl -G https://api.abuseipdb.com/api/v2/check \
	    --data-urlencode "ipAddress=${ipadr}" \
	    -d maxAgeInDays=3 \
	    -d verbose \
	    -H "Key: #your own API KEY#" \
	    -H "Accept: application/json"`
	echo ${curlr} > tmp-curl
    
	json=$(cat tmp-curl)
	for key in $(echo $json | jq -r keys[]); do
	    str1=`echo $json | jq '.data.reports[].comment'`
	    echo $ipadr","$str1
	done
     
     fi

    
     COUNT=`expr $COUNT + 1`

done < $1
