while read line; do
    ip=`echo $line | cut -d "," -f 2`
    echo $ip
    python slmbr.py $ip > tmp
    python 1.py tmp
    sleep 1s
done < $1
