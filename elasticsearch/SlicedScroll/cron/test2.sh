./build.sh count_destPort_final 
nLines=`wc -l all-dest_port | cut -d " " -f 1`
./count_destPort_final all-dest_port $nLines
sed -i '1s/^/"timestamp, portNo, counted, sum \n/' destPort_final
scp destPort_final 192.168.72.5:/root/splunk-session-port/

./build.sh count_sourcePort_final
nLines=`wc -l all-source_port | cut -d " " -f 1`
./count_sourcePort_final all-source_port $nLines
sed -i '1s/^/"timestamp, portNo, counted, sum \n/' sourcePort_final
scp sourcePort_final 192.168.72.5:/root/splunk-session-port/
