cd ./traverse2
make
cd ..
time ./traverse2/traverse2 $1 $2 > tmp

time ./reduce.sh tmp
time pig reduce2.pig > tmp2

python clean.py tmp2 > tmp3
./drem.pl tmp3 > tmp4

cat tmp4
python cut.py tmp4 $1
