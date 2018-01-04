SPLIT_LINES=10000

./build.sh group7

ls 2018* > list

while read line; do
    echo $line
    mkdir dir_${line}
    split -l $SPLIT_LINES $line $line-out
    mv $line-out* ./dir_${line}/
    cp group7.cpp ./dir_${line}/
    cp build.sh ./dir_${line}/
    cp timer.h ./dir_${line}/
    cp rename_and_do.sh ./dir_${line}/
done < list
