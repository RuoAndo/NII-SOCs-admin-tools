time ./do.sh list
python pair-count-7.py TARGET_20170704_0000-20170714_2359.csv tmp > tmp2
python 2.py tmp2 > tmp3
./label2.sh tmp3
./cat-avg.sh 
./cat-cls.sh 
python three.py cat-avg-all cat-cls-all > r
python 1.py r
