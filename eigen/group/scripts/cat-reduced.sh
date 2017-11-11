find . -maxdepth 1 -type d | grep dir > dirlist

rm -rf reduced_all
touch reduced_all

while read line; do
    echo $line
    #cd $Line
    #wc -l $line/reduced
    cat $line/reduced >> reduced_all
done < dirlist
