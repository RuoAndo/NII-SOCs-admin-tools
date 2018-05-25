#ls -t iplist/* | grep app > list

date=`date --date "1 days ago" +%Y%m%d`

ls iplist/* | grep reduced > list
dn=`grep $date list` #| cut -d "/" -f 2`
echo $dn

python cut.py $dn > tmp

fn=`echo $dn | cut -d "/" -f 2`
echo $fn
\cp tmp $fn

nLines_fn=`wc -l $fn | cut -d " " -f1`
echo $nLines_fn

var=5000
if [ $nLines_fn -gt $var ] ; then
    head -n 5000 $fn > tmp
    \cp tmp $fn
fi

echo "CHECK"
wc -l $fn

date_start=`date "+%s"`
time python lookup_ip_details.py scout.cfg $fn NII
date_end=`date "+%s"` 

diff=`echo $((date_end-date_start))`                       
div=`echo $((diff/60))`                                    
echo "proc time:"$diff"sec"                                
echo "proc time:"$div"min"   

rm -rf procTime
echo "proc time:"$diff"sec" > procTime                     
echo "proc time:"$div"min" >> procTime  

today=`echo $fn | cut -d "-" -f 4`
cp procTime procTime-${today}-$fn

\cp lg-$fn ./system_tags/

nTags=`wc -l lg-$fn | cut -d " " -f 1`
date=`echo $fn | cut -d "-" -f 4`
nLines=`echo $fn | cut -d "-" -f 7`
host=`echo $fn | cut -d "-" -f 3`
nIP=`wc -l $fn | cut -d " " -f 1`
cat lg-$fn
