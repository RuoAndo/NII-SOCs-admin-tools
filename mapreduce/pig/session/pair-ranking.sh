time ./pair-ranking-2.sh $1 > tmp
time ./pair-ranking-3.sh $1 > tmp
pig pair-ranking-4.pig $1 > tmp

