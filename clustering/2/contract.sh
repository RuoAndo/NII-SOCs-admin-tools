pyenv local system

d=6
n=10000000

nLines=`expr \( $d \* $n \) / 2`
echo $nLines

percent=`expr $nLines / 100`

rm gen-groupData.t.py

cat gen-groupData.py | sed "s/d = dCONSTANT/d = $d/" > gen-groupData.t1.py
cat gen-groupData.t1.py | sed "s/N = NCONSTANT/N = $n/" > gen-groupData.t.py

time python gen-groupData.t.py > tmp

split -l 1000000 tmp bk
ls bk* > list

COUNTER=0
while read line; do
    echo $line "->" $COUNTER
    cp $line $COUNTER
    COUNTER=`expr $COUNTER + 1`
done < list

cat group8.cpp | sed "s/#define N_LINES N/#define N_LINES $nLines/" > group8.tmp.cpp
cat group8.tmp.cpp | sed "s/#define N_PERCENT_LINES N/#define N_PERCENT_LINES $percent/" > group8.re.cpp
#cat group8.tmp.2.cpp | sed "s/leftCols(N)/leftCols($nDimensions)/" > group8.re.cpp

./build.sh group8.re

time ./group8.re

