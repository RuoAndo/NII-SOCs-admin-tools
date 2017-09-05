while read line; do
    #echo $line
    grep $line $2

    if [ $? -eq 0 ]; then
	echo $line 
    else
        :
    fi

done < $1
