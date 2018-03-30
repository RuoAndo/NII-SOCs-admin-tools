# first.sh
# input file: 0 (nDimensions * nLines)
# output file: 0.lbl

pyenv local system

d=6
n=10000000

nLines=`expr \( $d \* $n \) / 2`
echo $nLines

percent=`expr $nLines / 100`

rm gen-groupData.t.py

cat gen-groupData.py | sed "s/d = dCONSTANT/d = $d/" > gen-groupData.t1.py
cat gen-groupData.t1.py | sed "s/N = NCONSTANT/N = $n/" > gen-groupData.t.py

echo "generating data..."
time python gen-groupData.t.py > 0

#define N_LINES 3000000
#define N_PERCENT_LINES 30000 

#rm group8.re.cpp

cat group8.cpp | sed "s/#define N_LINES N/#define N_LINES $nLines/" > group8.tmp.cpp
cat group8.tmp.cpp | sed "s/#define N_PERCENT_LINES N/#define N_PERCENT_LINES $percent/" > group8.re.cpp
#cat group8.tmp.2.cpp | sed "s/leftCols(N)/leftCols($nDimensions)/" > group8.re.cpp

./build.sh group8.re

time ./group8.re
