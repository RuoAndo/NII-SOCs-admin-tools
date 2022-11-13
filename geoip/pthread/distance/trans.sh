while read line; do
    echo $line | sed -re 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/*.*.*.*/g' 
done < $1

