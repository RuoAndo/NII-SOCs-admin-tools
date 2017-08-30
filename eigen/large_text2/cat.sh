COUNTER=0
rm -rf all 
touch all
for line in `cat ${1}`
do
    cat $COUNTER >> all
    COUNTER=`expr $COUNTER + 1`
done
