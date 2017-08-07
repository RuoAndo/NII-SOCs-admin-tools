COUNTER=0
for line in `cat ${1}`
do
    python trans.py $line > tmp
    cp tmp $COUNTER
    COUNTER=`expr $COUNTER + 1`
done
