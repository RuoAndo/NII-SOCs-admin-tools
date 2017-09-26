COUNTER=0
for line in `cat ${1}`
do
    echo "now processing " $line ":" $COUNTER " ..."
    python trans.py $line > vldc_data
    cp vldc_data vldc_data$COUNTER
    COUNTER=`expr $COUNTER + 1`
done
