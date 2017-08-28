rm -rf nclstr.bak

python conv.py all > all-conv
./avg.sh all-conv
split -l 500000 all-conv out
ls out* > list
./rename.sh list
./core c 10 4 500000 5
ls *.labeled > list2
./cat.sh list2
python 0.py all2

#./avg2.sh all2
#python fill2.py c > c2
#./first c2 10 4 500000 5
#./cat.sh list2
#python 0.py all2
