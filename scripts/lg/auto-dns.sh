#ls -t iplist/* | grep app > list
#dn=`tail -n 1 list` #| cut -d "/" -f 2
#echo $dn

#date=`date --date "1 days ago" +%Y%m%d`
date=`date +%Y%m%d`
#ls -lt iplist/* | grep app > list
ls iplist/* | grep dns > list
#dn=`tail -n 1 list` #| cut -d "/" -f 2
dn=`grep $date list` #| cut -d "/" -f 2`
echo $dn

python cut.py $dn > tmp

#head -n 1000 tmp > tmp2
#head -n 1000 tmp 
#\cp tmp2 tmp

fn=`echo $dn | cut -d "/" -f 2`
echo $fn
\cp tmp $fn
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

python readjson.py $fn_ip_detailed_data.txt > lg-$fn
\cp lg-$fn ./system_tags/
#python readjson.py list_ip_detailed_data.txt 

nTags=`wc -l lg-$fn | cut -d " " -f 1`
date=`echo $fn | cut -d "-" -f 4`
nLines=`echo $fn | cut -d "-" -f 7`
host=`echo $fn | cut -d "-" -f 3`
nIP=`wc -l $fn | cut -d " " -f 1`
echo "iptags($nTags個) ($date:${nLines}億件:${nIP})につきまして"

echo "皆様
 
安藤です。お世話になっております。
$dateのセッションデータ${nLines}億件($host)より、$nTags個のiptagsを検出しましたのでご報告いたします。

ご多忙中恐縮ですが、よろしくご配意をお願い申し上げます。
安藤"

echo " " 

cat lg-$fn
