fn=`echo $1 | cut -d "/" -f 2`
echo $fn

python readjson.py ${fn}_ip_detailed_data.txt > lg-$fn
#python readjson.py ${fn} > lg-$fn
#python readjson.py list_ip_detailed_data.txt > K 

nTags=`wc -l lg-$fn | cut -d " " -f 1`
date=`echo $fn | cut -d "-" -f 4`
nLines=`echo $fn | cut -d "-" -f 6`
host=`echo $fn | cut -d "-" -f 3`
nIP=`wc -l $fn | cut -d " " -f 1`

#echo "【${host}】iptags($nTags個) $date:${nLines}億件:${nIP}IP:${host}につきまして"
echo "iptags($nTags個) $date:${nLines}億件:${host}につきまして"

echo "皆様
 
安藤です。お世話になっております。
$dateのセッションデータ${nLines}件($host)より、$nTags個のiptagsを検出しましたのでご報告いたします。

お手数をおかけしますが、よろしくご配意をお願い申し上げます。
安藤"

echo " " 

cat lg-$fn
