rm -f pig_*
pig -param SRCS=$1 avg.pig
