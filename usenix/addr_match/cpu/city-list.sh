cp /root/GeoLiteCity.dat .
cp /root/blacklist.txt ./
#./geo.sh blacklist.txt #| grep -i hainan | cut -d "," -f1 #> tmp
./geo.sh blacklist.txt | grep -i ${1} | cut -d "," -f1 > tmp
./append.sh tmp > list-${1}
#./multi_measure_2.sh ${1}
