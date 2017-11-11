./build.sh group7

ls 2017* > list

COUNTER=0
for line in `cat list`
do
    echo "now processing " $line ":" $COUNTER " ..."
    #python trans.py $line > $COUNTER
    \cp $line $COUNTER
    COUNTER=`expr $COUNTER + 1`
done

./group7
