date=`date --date '2 day ago' +%Y%m%d`
cd $date
\cp /data1/nii-cyber-security-admin/eigen/group/scripts/* .
time ./do-all.sh

