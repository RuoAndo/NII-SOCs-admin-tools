make
cp -r /mnt/count-session /root/
cp -r /data1/count-session /root/
./cp.sh
#time ./install.sh
time ./do-gendata.sh list instIDlist  
time ./auto.sh instIDlist 
