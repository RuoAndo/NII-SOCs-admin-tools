#procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
# r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
# 1  0  31684 54595608   2244 454274240    0    0    12    44    0    0  1  5 94  0  0

cat=`cat $1 | awk '{a+=$3} END{print a;}'`
echo swpd $cat
cat=`cat $1 | awk '{a+=$4} END{print a;}'`
echo free $cat
cat=`cat $1 | awk '{a+=$5} END{print a;}'`
echo buff $cat
cat=`cat $1 | awk '{a+=$6} END{print a;}'`
echo cache $cat
cat=`cat $1 | awk '{a+=$7} END{print a;}'`
echo si $cat
cat=`cat $1 | awk '{a+=$8} END{print a;}'`
echo so $cat
cat=`cat $1 | awk '{a+=$9} END{print a;}'`
echo bi $cat
cat=`cat $1 | awk '{a+=$10} END{print a;}'`
echo bo $cat
cat=`cat $1 | awk '{a+=$11} END{print a;}'`
echo "in" $cat
cat=`cat $1 | awk '{a+=$12} END{print a;}'`
echo cs $cat
cat=`cat $1 | awk '{a+=$13} END{print a;}'`
echo us $cat
cat=`cat $1 | awk '{a+=$14} END{print a;}'`
echo sy $cat
cat=`cat $1 | awk '{a+=$15} END{print a;}'`
echo id $cat
cat=`cat $1 | awk '{a+=$16} END{print a;}'`
echo wa $cat
cat=`cat $1 | awk '{a+=$17} END{print a;}'`
echo st $cat




