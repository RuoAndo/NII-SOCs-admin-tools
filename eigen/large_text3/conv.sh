COUNTER=0
for line in `cat ${1}`
do
    echo "now processing " $line ":" $COUNTER " ..."
    python conv.py $line > tmp
    cp tmp $COUNTER
    COUNTER=`expr $COUNTER + 1`
done
