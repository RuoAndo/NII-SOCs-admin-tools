cp ../piggybank.jar .
echo "label2.sh"
./label2.sh addrpair-join-all
echo "cat-cls.sh"
./cat-cls.sh
echo "cat-avg.sh"
./cat-avg.sh
echo "4.py"
time python three.py cat-avg-all cat-cls-all > r
time python 1.py r
