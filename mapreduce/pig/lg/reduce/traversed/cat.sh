rm -rf all-tmp
touch all-tmp

ls *_reduced > list-reduced

for line in `cat list-reduced`
do
    echo $line
    cat $line >> all-tmp
done
