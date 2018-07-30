d=`date --date '1 day ago' +%Y%m%d`
echo $d

nLines_fn=`wc -l $d | cut -d " " -f1`
echo "the number of IPs in: "$nLines_fn

cp $d $d.org

var=3000
if [ $nLines_fn -gt $var ] ; then
    echo "CUT: "$var
    head -n 3000 $d > tmp
    \cp tmp $d
fi 

#pyenv local system
/root/.pyenv/bin/pyenv local system
echo "querying ScoutVision 10.224.253.54..."
time /usr/bin/python2.7 lookup_ip_details.py scout.cfg $d NII

