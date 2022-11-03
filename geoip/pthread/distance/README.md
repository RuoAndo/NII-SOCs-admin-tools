# 0

split -n 400 iplist
mv xa* ./box/a
...

<pre>
# tree
\u251c\u2500\u2500 box
\u2502 \u251c\u2500\u2500 a
\u2502 \u2502 \u251c\u2500\u2500 xaa
\u2502 \u2502 \u251c\u2500\u2500 xab
\u2502 \u2502 \u251c\u2500\u2500 xac
\u2502 \u2502 \u251c\u2500\u2500 xad
\u2502 \u2502 \u251c\u2500\u2500 xae
</pre>

# 1
<pre>
 1 ./build.sh multi_measure_2
 2
 3 rm -rf log
 4 touch log
 5
 6 MINDIS=$1
 7 time ./multi_measure_2 box/a/ $MINDIS $2 | tee -a log
 8 time ./multi_measure_2 box/b/ $MINDIS $2 | tee -a log
 9 time ./multi_measure_2 box/c/ $MINDIS $2 | tee -a log
10 time ./multi_measure_2 box/d/ $MINDIS $2 | tee -a log
11 time ./multi_measure_2 box/e/ $MINDIS $2 | tee -a log
12 time ./multi_measure_2 box/f/ $MINDIS $2 | tee -a log
13 time ./multi_measure_2 box/g/ $MINDIS $2 | tee -a log
14 time ./multi_measure_2 box/h/ $MINDIS $2 | tee -a log
</pre>
