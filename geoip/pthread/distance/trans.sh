while read line; do
    #echo $line | sed -re 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/*.*.*.*/g' 
    IP=`echo $line | cut -d "," -f 1 | awk -F "." '{print $1.".*."$2.".*"}'`
    CNT=`echo $line | cut -d "," -f 2` # | awk -F "." '{print $1.".*."$2.".*"}'`

    echo $IP","$CNT
    
done < $1

