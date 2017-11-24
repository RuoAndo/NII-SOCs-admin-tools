ls -L1 /data1/count-session/ | grep 2017 > list 

while read line; do
    echo "copying "$line
    cp -r /data1/count-session/$line .
done < list
