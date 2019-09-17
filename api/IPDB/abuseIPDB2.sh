DATE=`date --date '2 day ago' +%Y-%m-%d`
#echo $DATE

COUNT=0

echo "timestamp, ipaddr, score, usage, isp, domain, nReports, reportedAt, isPublic, isWhitelisted, code, name"

while read line; do
    if [ $COUNT -gt 0 ] ; then

	ip=`echo $line | cut -d "," -f 1`
	ipadr=`echo $ip | sed -e 's/\"//g'`

	curlr=`curl -G https://api.abuseipdb.com/api/v2/check \
	    --data-urlencode "ipAddress=${ipadr}" \
	    -d maxAgeInDays=YOUR_SET \
	    -d verbose \
	    -H "Key: YOUR_KEY" \
	    -H "Accept: application/json"`
	echo ${curlr} > tmp-curl
    
	json=$(cat tmp-curl)
	for key in $(echo $json | /usr/local/bin/jq -r keys[]); do
	    str1=`echo $json | /usr/local/bin/jq '.data.reports[].comment' | sed -e s///g | sed -e s/\n//g | sed -e s/\r\n//g | sed -e s/\r//g`
	    str2=`echo $json | /usr/local/bin/jq '.data.abuseConfidenceScore'`
	    str3=`echo $json | /usr/local/bin/jq '.data.usageType'`
	    str4=`echo $json | /usr/local/bin/jq '.data.isp'`
	    str5=`echo $json | /usr/local/bin/jq '.data.domain'`
	    str6=`echo $json | /usr/local/bin/jq '.data.totalReports'`
	    str7=`echo $json | /usr/local/bin/jq '.data.lastReportedAt'`
	    str8=`echo $json | /usr/local/bin/jq '.data.isPublic'`
	    str9=`echo $json | /usr/local/bin/jq '.data.isWhitelisted'`
	    str10=`echo $json | /usr/local/bin/jq '.data.countryCode'`
	    str11=`echo $json | /usr/local/bin/jq '.data.countryName'`
	    echo -e $DATE" 00:00:00,"$ipadr","$str2","$str3","$str4","$str5","$str6","$str7","$str8","$str9","$str10","$str11","$str1

	done
     
     fi

    
     COUNT=`expr $COUNT + 1`

done < $1
