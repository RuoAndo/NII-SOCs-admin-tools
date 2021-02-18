YOUR_API_KEY="SET_YOUR_KEY"
curl -G https://api.abuseipdb.com/api/v2/blacklist \
-d countMinimum=15 \
-d maxAgeInDays=60 \
-d confidenceMinimum=90 \
-H "Key: $YOUR_API_KEY" \
-H "Accept: text/plain" > blacklist.txt

shuf -n 100 blacklist.txt > tmp
./append.sh tmp | tee list-abuseipdb

