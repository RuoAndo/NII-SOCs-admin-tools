ls 2017*_HIBETSU_*.csv > list
./concat.sh list
./group.sh all
cp dump-all/part-r-00000 . 
