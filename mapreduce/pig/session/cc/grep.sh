TESTFILE=$1
while read line; do
    grep $line $2
done < $TESTFILE

