COUNTER=0
for line in `cat ${1}`
do
    echo "now processing " $line ":" $COUNTER " ..."
    /home/flare/.pyenv/shims/python trans.py $line > $COUNTER
    COUNTER=`expr $COUNTER + 1`
done
