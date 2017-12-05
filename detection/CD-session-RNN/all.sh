./cp.sh
cp -r /mnt/count-session /root/
cp -r /data1/count-session /root/
#time ./install.sh
time ./do-gendata.sh list instIDlist  
time ./auto.sh instIDlist 
