python 3.py cat-avg-all cat-cls-all > r
./label2.sh r
./cat-cls.sh; ./cat-avg.sh
#python 3.py cat-avg-all cat-cls-all
python 3.py cat-avg-all cat-cls-all > r
python 1.py r
