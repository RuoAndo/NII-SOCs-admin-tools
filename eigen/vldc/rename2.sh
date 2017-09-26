COUNTER=0
for line in `cat ${1}`
do
    #cut=`echo $line | cut -d "." -f1`
    #echo $cut
    echo "now relabeling " vldc_relabel$COUNTER " to " vldc_label$COUNTER 
    \cp /dev/vldc_relabel$COUNTER /dev/vldc_label$COUNTER
    COUNTER=`expr $COUNTER + 1`
done
