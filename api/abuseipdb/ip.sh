curl -G https://api.abuseipdb.com/api/v2/check \
     --data-urlencode "ipAddress=$1" \
     -d maxAgeInDays=90 \
     -d verbose \
     -H "Key: $YOUR_API_KEY" \
     -H "Accept: application/json"

