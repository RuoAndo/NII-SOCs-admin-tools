COUNT=0

while [ $COUNT -lt 3 ]; do
    ./second.sh
    COUNT=`expr $COUNT + 1` 
done
