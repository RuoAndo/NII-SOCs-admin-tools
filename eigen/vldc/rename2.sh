COUNTER=0
for line in `cat ${1}`
do
    cut=`echo $line | cut -d "." -f1`
    #echo $cut
    echo "now relabeling " $line ":" $cut".labeled" " ..."
    \cp $line $cut.labeled
    COUNTER=`expr $COUNTER + 1`
done
