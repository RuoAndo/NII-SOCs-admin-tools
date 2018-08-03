
ls *csv > list

./build.sh count_pair_bytes_2.cpp

rm -rf all-reduced
touch all-reduced

while read line; do
    echo $line
    nLines=`wc -l $line | cut -d " " -f 1`
    echo $nLines
    ./a.out $line $nLines
    cat reduced >> all-reduced
done < list
