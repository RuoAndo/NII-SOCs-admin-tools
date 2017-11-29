#date=$(date "+%Y%m%d")
date=`date --date '2 day ago' +%Y%m%d`
find . -maxdepth 1 -type d | grep dir > dirlist

rm -rf reduced_all-$date
touch reduced_all-$date

while read line; do
    echo $line
    #cd $Line
    #wc -l $line/reduced
    cat $line/reduced >> reduced_all-$date
done < dirlist
