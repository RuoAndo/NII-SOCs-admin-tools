rm -rf all2
touch all2
for line in `cat ${1}`
do
    echo $line
    cat $line >> all2
done
