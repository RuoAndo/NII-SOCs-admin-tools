rm -rf all-tmp
touch all-tmp
for line in `cat ${1}`
do
    echo $line
    cat $line >> all-tmp
done
