ls iplist_* > list-iplist
rm -rf all_iplist
touch all_iplist

while read line; do
    echo $line
    cat $line >> all_iplist
done < list-iplist

./drem.pl all_iplist > all_iplist-drem
