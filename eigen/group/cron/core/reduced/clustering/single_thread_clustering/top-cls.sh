#!/bin/bash
#echo "execution started.."

top -b -n 3 | sed -n '7,1p' > out.txt

while [ true ]; do
    sleep 30
    #echo "running.."
    top -b -n 3 | sed -n '8, 12p' >> out.txt
done
