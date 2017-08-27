g++ data.c -fpermissive -lpthread -std=c++11
./label.sh $1 > $1-labeled
python clean.py $1-labeled > $1-labeled-clean
./avg.sh $1-labeled-clean > $1-avg
python clean.py $1-avg > $1-avg-clean
python trans.py $1 > $1-trans
cp $1-trans 0

# 5 CLUSTER, 4 dimension, 500000 lines, 4 dimension + 1 label
./a.out $1-avg-clean 10 4 500000 5 
python cat.py 0.para $1-avg-clean > c
python 0.py 0.para | tee cresult
cp cresult cresult.bak
./centroid c 10 5  > c2
python split.py c2 > c3
./distance c3 10 5 0.para-clean 500000 6 > tmp-r
python split.py tmp-r > tmp-r.csv
./reavg.sh tmp-r.csv 
