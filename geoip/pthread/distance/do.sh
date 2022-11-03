#./build.sh multi_measure_2

rm -rf log
touch log

MINDIS=$1

time ./multi_measure_2 box/a/ $MINDIS $2 | tee -a log
time ./multi_measure_2 box/b/ $MINDIS $2 | tee -a log
time ./multi_measure_2 box/c/ $MINDIS $2 | tee -a log
time ./multi_measure_2 box/d/ $MINDIS $2 | tee -a log
time ./multi_measure_2 box/e/ $MINDIS $2 | tee -a log
time ./multi_measure_2 box/f/ $MINDIS $2 | tee -a log
time ./multi_measure_2 box/g/ $MINDIS $2 | tee -a log
time ./multi_measure_2 box/h/ $MINDIS gx.txt | tee -a log
