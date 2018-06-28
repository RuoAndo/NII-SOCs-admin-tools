ls iplist-commerr-* > list-commerr

while read line; do
    echo $line
    python update-damballa.py $line
done < list-commerr

