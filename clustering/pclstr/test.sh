cat=`cat $3 | awk '{a+=$3} END{print a;}'`
echo swpd $cat
cat=`cat $4 | awk '{a+=$4} END{print a;}'`
echo free $cat
