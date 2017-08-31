while read line; do
    ip=`echo $line | cut -d "," -f 2`
    echo $ip
    python slmbr.py $ip > tmp
    
    result=`python 1.py tmp`  > tmp

    echo ${#result}

    if [ ${#result} -gt 10 ]; then
	echo "*" $ip
    fi

    sleep 1s
done < $1
