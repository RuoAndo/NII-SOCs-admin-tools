ls list-* | grep -v region > list-tmp

rm -rf list-aws-all

while read line; do
    echo $line
    cat $line >> list-aws-all
done < list-tmp


