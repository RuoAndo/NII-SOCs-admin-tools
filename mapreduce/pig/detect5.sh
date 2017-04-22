<<<<<<< HEAD
pig -param SRCS=$1 -param IP=$2 detect5.pig
=======
#!/bin/sh

TESTFILE=$1
while read line; do
    echo $line
    # pig -param SRCS=$line addrpair.pig
    pig -param SRCS=$line -param IP=$2 detect5.pig
done < $TESTFILE


>>>>>>> 6c86366ba3b43e6aa4c24bdbd914407692a8d2dc
