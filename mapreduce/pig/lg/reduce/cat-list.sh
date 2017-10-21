rm -rf list-all
touch list-all

while read line; do
    echo $line
    cat $line >> list-all
done < $1
