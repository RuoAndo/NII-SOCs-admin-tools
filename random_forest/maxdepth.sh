#!/bin/bash

COUNT=1

while [ $COUNT -lt 17 ]; do

    # 何かの処理
    echo "Depth :"$COUNT
    # ./3 $COUNT < in | grep Error
    ./3 $COUNT < in2 # | grep Error
    echo "-----"
    COUNT=`expr $COUNT + 1` # COUNT をインクリメント
done

