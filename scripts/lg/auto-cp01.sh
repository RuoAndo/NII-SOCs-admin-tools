date=`date --date "1 days ago" +%Y%m%d`
cd iplist
ls | grep cp01 > list
dn=`grep $date list` #| cut -d "/" -f 2`
echo $dn
cp $dn ../

cd ..

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

#python readjson.py $fn_ip_detailed_data.txt > lg-$fn
\cp lg-$fn ./system_tags/
#python readjson.py list_ip_detailed_data.txt 

nTags=`wc -l lg-$fn | cut -d " " -f 1`
date=`echo $fn | cut -d "-" -f 4`
nLines=`echo $fn | cut -d "-" -f 7`
host=`echo $fn | cut -d "-" -f 3`
nIP=`wc -l $fn | cut -d " " -f 1`
