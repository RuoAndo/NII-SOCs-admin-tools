date=`date --date '2 day ago' +%Y%m%d`
cd /data1/${date}_0
cp /data1/nii-cyber-security-admin/eigen/group/scripts-1_1000/* .
/data1/${date}_0/do-all.sh
/data1/${date}_0/cat-reduced.sh
