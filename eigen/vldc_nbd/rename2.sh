COUNTER=0
for line in `cat ${1}`
do
    #cut=`echo $line | cut -d "." -f1`
    #echo $cut
    echo "now relabeling " vldc_relabel_$COUNTER " to " vldc_label_$COUNTER 
    \cp /mnt/vldc_relabel_$COUNTER /mnt/vldc_label_$COUNTER
    COUNTER=`expr $COUNTER + 1`
done
