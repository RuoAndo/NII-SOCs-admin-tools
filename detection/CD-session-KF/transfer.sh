ls /data1/count-session/

while read line; do
    cp -r /data1/count-session/$line .
done < $1
