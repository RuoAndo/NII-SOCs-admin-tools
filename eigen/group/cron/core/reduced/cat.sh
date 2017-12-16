COUNT=$1

rm -rf reduce-all-tmp
touch reduce-all-tmp

#reduced_all_20171212

while [ $COUNT -le $2 ]; do
    cat reduced_all_$COUNT >> reduce-all-tmp
    COUNT=`expr $COUNT + 1` 
done
