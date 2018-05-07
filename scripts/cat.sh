ls | grep $1 > list

rm -rf all-$1
touch all-$1

cat HEADER/$1.csv > all-$1

while read line; do
    echo $line
    cat $line >> all-$1
done < list
