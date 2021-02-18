#!/bin/bash

#./ingress.sh city-name 11

NAME=${1}
END=${2}

COUNT=1
while [ $COUNT -lt $END ]; do

    cat ip-ingress_${1}-${COUNT}
    COUNT=`expr $COUNT + 1` # COUNT をインクリメント
done
