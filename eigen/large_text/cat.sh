COUNTER=0
rm -rf all 
touch all

rm -rf all-data 
touch all-data

for line in `cat ${1}`
do
    cat $COUNTER.para >> all
    cat $COUNTER >> all-data
    COUNTER=`expr $COUNTER + 1`
done
