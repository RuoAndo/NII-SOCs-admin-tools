cp ../piggybank.jar .
echo "label2.sh"
./label2.sh addrpair-join-all
echo "cat-cls.sh"
./cat-cls.sh
echo "cat-avg.sh"
./cat-avg.sh
echo "4.py"
python three.py cat-avg-all cat-cls-all > r
python time python 1.py r
