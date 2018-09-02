if [ "$1" = "" ]
then
    echo "./add-date-portNumber.sh start_date end_date DIR"
    exit 1
fi

START_DATE=$1
END_DATE=$2

rm -rf all-dest_ip
touch all-dest_ip

rm -rf all-source_ip
touch all-source_ip

echo "timestamp, ipaddr, counted" >> all-dest_ip
echo "timestamp, ipaddr, counted" >> all-source_ip

for (( DATE=${START_DATE} ; ${DATE} <= ${END_DATE} ; DATE=`date -d "${DATE} 1 day" '+%Y%m%d'` )) ; do

  echo ${DATE}

  cp add-date-IP.py ${DATE}

  cp *.sh ${DATE}
  cp *.cpp ${DATE}
  cp *.h ${DATE}
  cp *.hpp ${DATE}

  cd ${DATE}

  #####
  echo "catting...."
  ./cat.sh

  echo "spliting..."

  split -l 100000000 all spl.
  ls spl.* > list-spl

  rm -rf tmp-source
  touch tmp-source

  rm -rf tmp-dest
  touch tmp-dest
  
  while read line; do
    echo "counting lines..."
    echo $line
    nLines=`wc -l ${line} | cut -d " " -f 1`
    echo $nLines

    echo "count dest ip"
    time ./build.sh count_dest_ip 
    ./count_dest_ip ${line} $nLines
    cat dest_ip >> tmp-dest

    echo "count source ip"
    time ./build.sh count_source_ip 
    ./count_source_ip ${line} $nLines
    cat source_ip >> tmp-source

  done < list-spl

  \cp tmp-dest dest_ip
  \cp tmp-source source_ip

  #####

  python add-date-IP.py dest_ip ${DATE} >> ../all-dest_ip
  python add-date-IP.py source_ip ${DATE} >> ../all-source_ip

  cd ..
done

nLines=`wc -l all-dest_ip | cut -d "" -f 1`
./build.sh count_destIP_final 
./count_destIP_final all-dest_ip $nLines
sed -i -e '1,1d' destIP_final
cp destIP_final destIP_final-${START_DATE}-${END_DATE}
scp destIP_final-${START_DATE}-${END_DATE} 192.168.72.5:/mnt/sdc/splunk-session/gpu

nLines=`wc -l all-dest_ip | cut -d "" -f 1`
./build.sh count_sourceIP_final
./count_sourceIP_final all-source_ip $nLines
sed -i -e '1,1d' sourceIP_final
cp sourceIP_final sourceIP_final-${START_DATE}-${END_DATE}
scp sourceIP_final-${START_DATE}-${END_DATE} 192.168.72.5:/mnt/sdc/splunk-session/gpu
