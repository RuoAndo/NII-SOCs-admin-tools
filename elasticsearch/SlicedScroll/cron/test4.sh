#nLines=`wc -l all-dest_ip | cut -d " " -f 1`
#echo $nLines
#./build.sh count_destIP_final 
#./count_destIP_final all-dest_ip $nLines
#scp destIP_final 192.168.72.5:/root/splunk-session-port/

nLines=`wc -l all-source_ip | cut -d " " -f 1`
echo $nLines
./build.sh count_sourceIP_final
./count_sourceIP_final all-source_ip $nLines
scp sourceIP_final 192.168.72.5:/root/splunk-session-port/
