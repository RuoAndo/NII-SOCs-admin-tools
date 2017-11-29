ls *_reduced > list-reduce
rm -rf all_reduce
touch all_reduce

while read line; do
    echo $line
    cat $line >> all_reduce
done < list-reduce

./drem.pl all_reduce > all_reduce-drem
