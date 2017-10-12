#!/bin/bash
hander()
{
 #echo "recv!!"
./aggregate.sh tmp
 exit 
}

trap hander SIGINT

./iostat.sh $1 | tee tmp
while /bin/true; do    :    ; done



