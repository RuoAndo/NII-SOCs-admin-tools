# cron at edge

<pre>
0 0 * * * cd /data1; ./reduce-daily-1_1000.sh >> reduce.log 2>> reduce.log
30 21 * * * reboot
55 21 * * * cd /data1; ./cat-reduced-daily.sh
0 22 * * * cd /data1; ./scp.sh
0 23 * * * cd /data1; ./remove.sh
</pre>

0 0 * * * cd /data1; ./reduce-daily-1_1000.sh >> reduce.log 2>> reduce.log
<pre>
date=`date --date '2 day ago' +%Y%m%d`
cd /data1/${date}_0
cp /data1/nii-cyber-security-admin/eigen/group/scripts-1_1000/* .
/data1/${date}_0/do-all.sh
/data1/${date}_0/cat-reduced.sh
</pre>

55 21 * * * cd /data1; ./cat-reduced-daily.sh
<pre>
date=`date --date '2 day ago' +%Y%m%d`
cd /data1/${date}_0
./cat-reduced.sh
</pre>

0 22 * * * cd /data1; ./scp.sh
<pre>
date=`date --date '2 day ago' +%Y%m%d`                                                                                  
echo "erasing split files..."                                                                                           
rm -rf ${date}_0/201*                                                                                                   
echo "transferring..."                                                                                                  
time scp -r ${date}_0 192.168.72.5:/mnt/sdc/reduced   
</pre>

0 23 * * * cd /data1; ./remove.sh
<pre>
date=`date --date '5 day ago' +%Y%m%d`
rm -rf $date
rm -rf ${date}_0
rm -rf ${date}_1
</pre>

