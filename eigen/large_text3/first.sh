./piggybank.sh
./build.sh
rm -rf nclstr.bak
rm -rf process

python conv.py all > all-conv
split -l 500000 all-conv out
ls out* > list
./rename.sh list

./avg.sh all-conv # generates "avg-all-conv" and "c"
./core c 10 4 500000 5

ls *.labeled > list2
./cat.sh list2
python 0.py all2

python concate.py all2 c avg-all-conv > c2                   
# c2 nPoints, clusterNo, received, sent, sidc
# 0,0,4254.970199115338,11538.261469900643,2.557382710801764
# 435164,1,1300.0852150323146,11533.86312135961,2.542900077129711

