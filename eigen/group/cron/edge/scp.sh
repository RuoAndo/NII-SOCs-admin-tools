date=`date --date '2 day ago' +%Y%m%d`                                                                                    
echo "erasing split files..."                                                                                             
rm -rf ${date}_0/201*                                                                                                     
echo "transferring..."                                                                                                    
time scp -r ${date}_0 192.168.72.5:/mnt/sdc/reduced   
