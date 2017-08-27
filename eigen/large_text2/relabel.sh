./centroid2 c3 10 5 $1 10 5 > new-centroid
python split.py new-centroid > new-centroid.csv 

time ./distance new-centroid.csv 10 5 0.para-clean 500000 6 > tmp-r 
time python split.py tmp-r > tmp-r.csv
time ./reavg.sh tmp-r.csv
python 1.py tmp-r.csv cresult.bak | tee cresult
cat cresult >> cresult2
cat cresult | grep CLUSTER > cresult.bak
