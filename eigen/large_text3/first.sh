rm -rf nclstr.bak

python conv.py all > all-conv
./avg.sh all-conv # generates "avg-all-conv" and "c"

split -l 500000 all-conv out
ls out* > list
./rename.sh list

./core c 10 4 500000 5

ls *.labeled > list2
./cat.sh list2

#python 0.py all2

python concate.py all2 avg-all-conv > c2                    
#0,0,4254.970199115338,11538.261469900643,2.557382710801764
#435164,1,1300.0852150323146,11533.86312135961,2.542900077129711

