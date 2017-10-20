if [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" == "" ];
then
    echo "argument required: ./do.sh ipaddress dir title"
fi

cd ./traverse2
make
cd ..
time ./traverse2/traverse2 $1 $2 > tmp

time ./reduce.sh tmp
time pig reduce2.pig > tmp2

python clean.py tmp2 > tmp3
./drem.pl tmp3 > tmp4

#cat tmp4
python dir.py tmp4 $1 > tmp5
python cut.py tmp4 $1 > tmp6

python dir.py tmp4 $1 > reduce-$3-$1-$4-`date +%Y%m%d_%H-%M`
\cp reduce-$3-$1-$4-`date +%Y%m%d_%H-%M` /data1/reduced-data/

#python cut.py tmp4 $1 > reduce-$3-$1-$4-list-`date +%Y%m%d_%H-%M`
#\cp reduce-$3-$1-$4-list-`date +%Y%m%d_%H-%M` /data1/reduced-data/

python cut.py tmp4 $1 > list-reduce-$3-$1-$4-`date +%Y%m%d_%H-%M`
\cp list-reduce-$3-$1-$4-`date +%Y%m%d_%H-%M` /data1/reduced-data/

#./slmbr.sh 1 > tmp-s
