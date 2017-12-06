ls -L1 /root/count-session/ | grep 2017 > list 

while read line; do
    echo "copying "$line
    cp -r /root/count-session/$line .
done < list
