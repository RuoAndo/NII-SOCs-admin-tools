#!/bin/sh
# ファイルを1行ずつ読み込んで表示

while read line; do
    #echo $line
    str=`geoiplookup $line | grep City`
    echo $line","$str
done < $1

