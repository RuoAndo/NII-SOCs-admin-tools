#!/bin/bash
hander()
{
 #echo "recv!!"
./aggregate.sh tmp
 exit 
}

trap hander SIGINT

./iostat.sh $line | tee tmp
while /bin/true; do    :    ; done



