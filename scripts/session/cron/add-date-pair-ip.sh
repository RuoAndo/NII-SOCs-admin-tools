#!/bin/bash

if [ "$1" = "" ]
then
    echo "./add-date-pair-ip.sh DIR"
    exit 1
fi

START_DATE=`date --date '3 day ago' +%Y%m%d`
END_DATE=`date --date '3 day ago' +%Y%m%d`

#START_DATE=$1
#END_DATE=$2

rm -rf tmp-pair-ip
touch tmp-pair-ip

echo "timestamp, srcIP, srcPort, destIP, destPort, counted" >> tmp-pair-ip-port

for (( DATE=${START_DATE} ; ${DATE} <= ${END_DATE} ; DATE=`date -d "${DATE} 1 day" '+%Y%m%d'` )) ; do

  echo ${DATE}

  #cp add-date-pair.py ${DATE}

  cp *.sh ${DATE}
  cp *.cpp ${DATE}
  cp *.h ${DATE}
  cp *.hpp ${DATE}
  cp *.py ${DATE}

  cd ${DATE}

  #####

  echo "catting...."
  ./cat.sh
  
  echo "spliting..."
  split -l 100000000 all spl.
  
  ls spl.* > list-spl

  rm -rf tmp-pair-ip
  touch tmp-pair-ip

  #rm -rf tmp-dest
  #touch tmp-dest
  
  while read line; do
    echo "counting lines..."
    echo $line
    nLines=`wc -l ${line} | cut -d " " -f 1`
    echo $nLines

    echo "count ip pair"
    time ./build.sh count_pair_ip
    ./count_pair_ip ${line} $nLines
    cat pair_ip >> tmp-pair-ip

  done < list-spl

  #####

  python add-date-pair-ip.py tmp-pair-ip ${DATE} >> ../all-pair-ip

  cd ..
done

nLines=`wc -l all-pair-ip | cut -d " " -f 1`
echo $nLines
./build.sh count_pair_ip_final
./count_pair_ip_final all-pair-ip $nLines
python add-date-pair-ip.py pair_ip_final ${START_DATE} > pair_ip_final-tmp
cp pair_ip_final-tmp pair_ip_final-${START_DATE}-${END_DATE}
scp pair_ip_final-${START_DATE}-${END_DATE} 192.168.72.5:/mnt/sdc/splunk-session/$1

