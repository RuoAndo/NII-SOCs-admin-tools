if [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" == "" ];
then
    echo "argument required: ./do.sh ipaddress dir title"
fi

mkdir reduced-data

cd ./traverse2
make
cd ..
time ./traverse2/traverse2 $1 $2 > tmp

d=`date --date '1 day ago' +%Y%m%d`
mkdir traversed
mkdir traversed/$d
cp tmp traversed/$d/traversed-$1-$3-$d

time ./reduce.sh tmp
time pig reduce2.pig > tmp2 #2>&1

python clean.py tmp2 > tmp3
./drem.pl tmp3 > tmp4

#cat tmp4
python dir.py tmp4 $1 > tmp5
python cut.py tmp4 $1 > tmp6

python dir.py tmp4 $1 > reduce-$3-$1-$4-`date +%Y%m%d_%H-%M`
\cp reduce-$3-$1-$4-`date +%Y%m%d_%H-%M` ./reduced-data/

#python cut.py tmp4 $1 > reduce-$3-$1-$4-list-`date +%Y%m%d_%H-%M`
#\cp reduce-$3-$1-$4-list-`date +%Y%m%d_%H-%M` /data1/reduced-data/

python cut.py tmp4 $1 > list-reduce-$3-$1-$4-`date +%Y%m%d_%H-%M`
\cp list-reduce-$3-$1-$4-`date +%Y%m%d_%H-%M` ./reduced-data/

#./slmbr.sh 1 > tmp-s
