if [ "$1" = "" ]
then
    echo "no argument. ./a.out yyyy mm dd"
    exit
fi

cp -r /data1/count_Alarm_Each/FirePOWER/2017* . 

./listup.pl | grep HIBETSU > csvlist
python trans-sort.py csvlist 
ls *csv > csvlist
echo "sorting csvlist..."  
./sort-csvlist.pl csvlist > csvlist-sorted
python cat-all.py csvlist-sorted > tmp
./sort-fp.pl tmp > tmp-sorted
python date-trans2.py tmp-sorted $1 $2 $3 > tmp-sorted-dated
