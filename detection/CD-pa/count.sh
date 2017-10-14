if [ "$1" = "" ]
then
    echo "no argument. ./a.out yyyy mm dd"
    exit
fi

python cat-all.py csvlist-sorted > tmp
./sort-fp.pl tmp > tmp-sorted
python date-trans2.py tmp-sorted $1 $2 $3 > tmp-sorted-dated
