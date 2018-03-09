pyenv local system

d=6
n=10000000

nLines=`expr \( $d \* $n \) / 2`
echo $nLines

percent=`expr $nLines / 100`

cat group8.cpp | sed "s/#define N_LINES N/#define N_LINES $nLines/" > group8.tmp.cpp
cat group8.tmp.cpp | sed "s/#define N_PERCENT_LINES N/#define N_PERCENT_LINES $percent/" > group8.re.cpp
#cat group8.tmp.2.cpp | sed "s/leftCols(N)/leftCols($nDimensions)/" > group8.re.cpp

./build.sh group8.re

time ./group8.re

