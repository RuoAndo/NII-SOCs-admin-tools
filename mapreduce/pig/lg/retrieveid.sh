TESTFILE=$1
while read line; do
    srcIP=`echo $line | cut -d "," -f1`
    destIP=`echo $line | cut -d "," -f1`
    
    #echo $srcIP
    #echo $destIP

    grep $srcIP $2 | grep $destIP

done < $TESTFILE


