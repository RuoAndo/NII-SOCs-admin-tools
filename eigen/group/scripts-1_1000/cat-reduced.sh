today=$(date "+%Y%m%d")

find . -maxdepth 1 -type d | grep dir > dirlist

rm -rf reduced_all-$today
touch reduced_all-$today

while read line; do
    echo $line
    #cd $Line
    #wc -l $line/reduced
    cat $line/reduced >> reduced_all-$today
done < dirlist
