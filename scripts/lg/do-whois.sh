while read line; do
    #echo $line
    w=`whois $line | grep person | cut -d ":" -f 2` 
    w2=`echo $w | sed "s/ /_/g"`
    #echo $w2

    if [ -n $w2 ]; then
	echo $line":"$w2
    fi

done < $1
