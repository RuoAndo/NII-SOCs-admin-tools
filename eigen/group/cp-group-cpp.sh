while read line; do
    echo $line
    cp $1 $line/
    echo $line/$1
    git add ./$line/$1
done < $2

