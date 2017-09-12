first.sh requires files of 'all' and 'list'.

<pre>

./piggybank.sh
./build.sh
rm -rf nclstr.bak
rm -rf process

python conv.py all > all-conv
split -l 500000 all-conv out
ls out* > list
#head -n 75 list > list-tmp
./rename.sh list

hadoop dfsadmin -safemode leave
./avg.sh all-conv # generates "avg-all-conv" and "c"
./core c 10 4 500000 5

ls *.labeled > list2
./cat.sh list2
python 0.py all2

python concate.py all2 c avg-all-conv > c2                   
./sort.pl c2 > c2-sorted

</pre>