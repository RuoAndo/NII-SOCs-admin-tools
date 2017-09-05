cd ./traverse2
make
cd ..

while read line; do
    echo $line
    time ./traverse2/traverse2 $line $2 > tmp-$line
done < $1



