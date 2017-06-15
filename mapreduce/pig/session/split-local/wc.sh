TESTFILE=$1
while read line; do
    fn=`readlink -f $line`
    wc -l $fn
done < $1

