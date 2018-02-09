COUNTER=0
for line in `cat ${1}`
do
    \cp $line $COUNTER
    #echo "now processing " $line ":" $COUNTER " ..."
    #python trans.py $line > $COUNTER
    COUNTER=`expr $COUNTER + 1`
done
