COUNTER=0
for line in `cat ${1}`
do
    rm -rf $COUNTER
    COUNTER=`expr $COUNTER + 1`
done
