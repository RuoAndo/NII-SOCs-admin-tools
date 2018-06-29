d=`date --date '1 day ago' +%Y%m%d`
echo $d
python lookup_ip_details.py scout.cfg $d NII
