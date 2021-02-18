cp /root/GeoLiteCity.dat .
cp /root/blacklist.txt .
./geo.sh blacklist.txt  | grep -i ${1} #| cut -d "," -f 1
