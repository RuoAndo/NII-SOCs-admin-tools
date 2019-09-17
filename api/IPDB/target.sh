DATE=`date --date '3 day ago' +%Y%m%d`
echo $DATE

rm target-${DATE}.csv
shuf -n 20 target.csv > tmpfile_target
cp tmpfile_target target-${DATE}.csv
#cp target.csv target-${DATE}.csv

rm -rf splunk-abuseIPDB-target-${DATE}.csv

./abuseIPDB2.sh target-${DATE}.csv > splunk-abuseIPDB-target-${DATE}.csv
/usr/bin/nkf -Lu -x -w80 splunk-abuseIPDB-target-${DATE}.csv | tr -d "\r" > splunk-abuseIPDB-target-current.csv
cp splunk-abuseIPDB-target-current.csv ./PaloAlto/splunk-abuseIPDB-target-${DATE}.csv
