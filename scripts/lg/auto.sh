python cut.py $1 > tmp

fn=`echo $1 | cut -d "/" -f 2`
echo $fn
\cp tmp $fn

time python lookup_ip_details.py scout.cfg $fn NII
 
python readjson.py $fn_ip_detailed_data.txt 
python readjson.py list_ip_detailed_data.txt > lg-$fn

nTags=`wc -l lg-$fn | cut -d " " -f 1`

date=`echo $fn | cut -d "-" -f 4`

nLines=`echo $fn | cut -d "-" -f 7`

host=`echo $fn | cut -d "-" -f 3`

nIP=`wc -l $fn | cut -d " " -f 1`

echo "iptags($nTags個) ($date:${nLines}億件:${nIP})IPにつきまして"

echo "皆様
 
安藤です。お世話になっております。
$dateのセッションデータ${nLines}億件($host)より、$nTags個のiptagsを検出しましたのでご報告いたします。

数が多くなってきましたので、現在出力の分析・蓄積方法を検討中です。
ご多忙中恐縮ですが、よろしくご配意をお願い申し上げます。
安藤"

echo " " 

cat lg-$fn
