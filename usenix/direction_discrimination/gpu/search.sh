while read line; do
    grep $line $2/*
done < $1
