ls delta-sorted* > list-tmp

./sort-latest-delta.pl list-tmp > list-tmp-sorted
fn=`head -n 1 list-tmp-sorted`
echo "the latest file is "$fn

cat ./$fn | awk 'BEGIN {FS=",";OFS=","} {print $3}' > $fn-iplist

nLines_fn=`wc -l $fn-iplist | cut -d " " -f1`
echo "the number of IPs in: "$nLines_fn

var=100
if [ $nLines_fn -gt $var ] ; then
    echo "CUT: "$var
    head -n 100 $fn-iplist > tmp
    \cp tmp $fn-iplist
fi 

pyenv local system
echo "querying ScoutVision 10.224.253.54..."
time /usr/bin/python2.7 lookup_ip_details.py scout.cfg $fn-iplist NII

mv ${fn}-iplist_ip_detailed_data.txt ../iplist-delta-lg/${fn}_ip_detailed_data.txt
rm -rf ${fn}
