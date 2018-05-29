#ls -t iplist/* | grep app > list

cd iplist
ls * | grep packets > list-reduced
mv list-reduced ../
cd ..

./sort-reduced.pl list-reduced > list-reduced-sorted
fn=`head -n 1 list-reduced-sorted`
echo $fn

cd iplist

sleep 10s

nLines_fn=`wc -l $fn | cut -d " " -f1`
echo $nLines_fn

var=100
if [ $nLines_fn -gt $var ] ; then
    head -n 100 $fn > tmp
    \cp tmp $fn
fi

echo "lg"
time python lookup_ip_details.py scout.cfg $fn NII
