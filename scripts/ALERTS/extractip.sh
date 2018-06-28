DATE=`date --date '1 day ago' +%Y%m%d` 
echo $DATE

cp iplist/series iplist/series.bak.${DATE}

echo "TARGET"
python extractip-target.py all-TARGET > iplist/iplist-target-${DATE}
wc -l iplist/iplist-target-${DATE}
nWcT=`wc -l iplist/iplist-target-${DATE} | cut -d " " -f 1`

echo "ATTACK"
python extractip-attack.py all-ATTACK > iplist/iplist-attack-${DATE}
wc -l iplist/iplist-attack-${DATE}
nWcA=`wc -l iplist/iplist-attack-${DATE} | cut -d " " -f 1`

echo "COMMERR"
python extractip-commerr.py all-COMMERR > iplist/iplist-commerr-${DATE}
wc -l iplist/iplist-commerr-${DATE}
nWcC=`wc -l iplist/iplist-target-${DATE} | cut -d " " -f 1`

cat iplist/iplist-target-${DATE} >> iplist-all-${DATE}
cat iplist/iplist-attack-${DATE} >> iplist-all-${DATE}
cat iplist/iplist-commerr-${DATE} >> iplist-all-${DATE}
./drem.pl iplist-all-${DATE} > iplist-all-${DATE}-drem
rm -rf iplist-all-${DATE}
mv iplist-all-${DATE}-drem ./iplist/iplist-all-${DATE}

DATE=`date --date '1 day ago' +%Y/%m/%d` 
echo $DATE","$nWcT","$nWcA","$nWcC
echo $DATE","$nWcT","$nWcA","$nWcC >> iplist/series

DATE=`date --date '1 day ago' +%Y%m%d` 
DATEA=`date --date '2 day ago' +%Y%m%d` 

cd iplist
cat iplist-target-${DATEA} iplist-target-${DATE} | sort | uniq -d > diff-target-${DATE}-${DATEA}
cat iplist-attack-${DATEA} iplist-attack-${DATE} | sort | uniq -d > diff-attack-${DATE}-${DATEA}
cat iplist-commerr-${DATEA} iplist-commerr-${DATE} | sort | uniq -d > diff-commerr-${DATE}-${DATEA}
