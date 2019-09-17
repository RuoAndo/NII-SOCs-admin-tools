while read line; do
    #echo $line | sed -e s/\n//g
    echo $line | sed -e 's/\r\n/-/' | sed -e 's/\n//'
    echo ""
done < $1
