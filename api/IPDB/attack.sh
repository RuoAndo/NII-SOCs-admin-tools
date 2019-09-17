DATE=`date --date '3 day ago' +%Y%m%d`
echo $DATE

rm attack-${DATE}.csv
shuf -n 20 attack.csv > tmpfile_attack
cp tmpfile_attack attack-${DATE}.csv
#cp attack.csv attack-${DATE}.csv

rm -rf splunk-abuseIPDB-attack-${DATE}.csv

./abuseIPDB2.sh attack-${DATE}.csv > splunk-abuseIPDB-attack-${DATE}.csv
/usr/bin/nkf -Lu -x -w80 splunk-abuseIPDB-attack-${DATE}.csv | tr -d "\r" > splunk-abuseIPDB-attack-current.csv
cp splunk-abuseIPDB-attack-current.csv ./FirePower/splunk-abuseIPDB-attack-${DATE}.csv
