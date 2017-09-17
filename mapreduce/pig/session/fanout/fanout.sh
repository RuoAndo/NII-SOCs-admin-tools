./piggybank.sh
pig -param SRCS=$1 -param LOGDATE=`date +"%Y_%m_%d_%I_%M_%S"` fanout.pig
