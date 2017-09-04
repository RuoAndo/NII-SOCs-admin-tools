while read line; do
    ip=`echo $line | cut -d "," -f 2`
    #echo $ip

    python slmbr.py $ip > tmp
    result=`python cm.py tmp`  

    if [ ${#result} -gt 10 ]; then
	echo "*" $ip
	python cm.py tmp
    fi

    sleep 1s
done < $1
