if [ "$2" = "" ]
then
    echo "argument required: ./cp-group-cpp file_to_copy file_dirlist"
    exit
fi

while read line; do
    echo $line
    cp $1 $line/
    echo $line/$1
    git add ./$line/$1
done < $2

