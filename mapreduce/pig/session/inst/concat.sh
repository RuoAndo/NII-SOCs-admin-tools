rm -rf all
touch all

while read line; do
    python trans.py $line > $line-trans
    cat $line-trans >> all
done < $1
