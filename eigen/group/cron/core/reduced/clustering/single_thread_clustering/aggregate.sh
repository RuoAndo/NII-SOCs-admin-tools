

#cat=`cat $1 | awk '{a+=$1} END{print a;}'`
#echo user `expr $cat/1000 | bc -l`
cat=`cat $1 | awk '{a+=$9} END{print a;}'`
echo rrpm/s $cat
cat=`cat $1 | awk '{a+=$10} END{print a;}'`
echo wrqm/s $cat
cat=`cat $1 | awk '{a+=$11} END{print a;}'`
echo r/s $cat
cat=`cat $1 | awk '{a+=$12} END{print a;}'`
echo w/s $cat
cat=`cat $1 | awk '{a+=$13} END{print a;}'`
echo rsec/s $cat
cat=`cat $1 | awk '{a+=$14} END{print a;}'`
echo wsec/s $cat
cat=`cat $1 | awk '{a+=$15} END{print a;}'`
echo avgrq-sz $cat
cat=`cat $1 | awk '{a+=$16} END{print a;}'`
echo avgqu-sz $cat
cat=`cat $1 | awk '{a+=$17} END{print a;}'`
echo await $cat
cat=`cat $1 | awk '{a+=$18} END{print a;}'`
echo svctm $cat




