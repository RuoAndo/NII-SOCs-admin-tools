python lookup_ip_details.py scout.cfg $1 NII
tmp=`echo $1 | cut -d "." -f1`
echo $tmp
python readjson.py $tmp"_ip_detailed_data.txt"