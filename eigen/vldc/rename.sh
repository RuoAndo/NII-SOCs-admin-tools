COUNTER=0
for line in `cat ${1}`
do
    echo "now processing " $line ":" $COUNTER " ..."
    python trans.py $line > /dev/vldc_data
    cp /dev/vldc_data /dev/vldc_data$COUNTER
    COUNTER=`expr $COUNTER + 1`
done
