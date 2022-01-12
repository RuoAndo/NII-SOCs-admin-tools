<pre>
YOUR_API_KEY="SET_YOUR_KEY"
curl -G https://api.abuseipdb.com/api/v2/blacklist \
-d countMinimum=15 \
-d maxAgeInDays=60 \
-d confidenceMinimum=90 \
-H "Key: $YOUR_API_KEY" \
-H "Accept: text/plain" > blacklist.txt

shuf -n 100 blacklist.txt > tmp
./append.sh tmp | tee list-abuseipdb
</pre>

<hr>
<pre>
# cat log | jq . > all
# ./scatter.sh all

--- scatter.sh ---

cat $1 | jq -j '.data.ipAddress,",",.data.countryCode,"\n"' > tmp
./match.sh tmp cc-numbered > tmp2   
   
cat $1 | jq -j '.data.ipAddress,",",.data.usageType,"\n"' | tr -d "\/" | tr -d " " > tmp3 
./match.sh tmp3 usageType-numbered > tmp4
     
paste tmp2 tmp4 -d"," > tmp5
cat tmp5 | cut -d "," -f6,3 > plot-$1
     
python scatter.py plot-$1
</pre>
