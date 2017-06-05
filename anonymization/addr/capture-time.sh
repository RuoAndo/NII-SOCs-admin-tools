rm -rf stmp
pig -x local -param SRCS=$1 capture-time.pig
