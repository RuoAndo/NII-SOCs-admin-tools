date=`date --date "1 days ago" +%Y%m%d`
#ls -lt iplist/* | grep app > list
ls delta/* | grep delta > list
#dn=`tail -n 1 list` #| cut -d "/" -f 2
fn=`grep $date list` #| cut -d "/" -f 2`
echo $fn

head -n 500 $fn > tmp
python cut-delta.py tmp > $fn

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

python readjson.py $fn_ip_detailed_data.txt 
