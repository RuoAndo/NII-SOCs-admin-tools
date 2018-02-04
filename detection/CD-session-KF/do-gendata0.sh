#!/bin/sh

date8=`date --date '8 day ago' +%Y%m%d`
date7=`date --date '7 day ago' +%Y%m%d`
date6=`date --date '6 day ago' +%Y%m%d`
date5=`date --date '5 day ago' +%Y%m%d`
date4=`date --date '4 day ago' +%Y%m%d`
date3=`date --date '3 day ago' +%Y%m%d`
date2=`date --date '2 day ago' +%Y%m%d`
date1=`date --date '1 day ago' +%Y%m%d`

rm -rf list
touch list

tree -d | grep 201 | cut -d " " -f2 > list0
cat list0

#grep $date8 list0 >> list
#grep $date7 list0 >> list
#grep $date6 list0 >> list
#grep $date5 list0 >> list
#grep $date4 list0 >> list
#grep $date3 list0 >> list
grep $date2 list0 >> list
grep $date1 list0 >> list

cat list

#if [ "$2" = "" ]
#then
#    echo "no argument: time ./do-gendata.sh instIDlist"
#    exit
#fi

if [ ! -e instIDlist ]; then

    echo "no instIDlist. copy..."
    loc=`locate instIDlist`
    cp $loc .
    echo "no instlist. copy..."
    loc=`locate instlist`
    cp $loc .
    
fi

###############################

pyenv local system

HOME=`pwd`

rm -rf in_*
rm -rf out_*

while read line; do
    #\cp -r /data1/count-session/$line .
    \cp -r /root/$line .

    echo $line
    cd $line

    \cp ../gendata/*.py .
    \cp ../gendata/*.pl .
    \cp ../gendata/*.sh .
    \cp ../instlist . 

    rm -rf in_*
    rm -rf out_*
    
    ./trans.sh 
    ./gen-data2.sh # yields *_in and *_out
    
    ls in_* > inlist
    while read line2; do
	echo $line2
	echo $line2_$line
	cp $line2 ${line2}_${line}
	cp ${line2}_${line} ../
    done < inlist

    ls out_* > outlist
    while read line2; do
	echo $line2
	echo $line2_$line
	cp $line2 ${line2}_${line}
	cp ${line2}_${line} ../
    done < outlist

    cd $HOME
    
done < list

while read line; do
    echo "ID: " ${line}

    ls in_${line}* > inlist_${line}

    while read line2; do
	echo "cat " ${line2}
	cat ${line2} >> in_${line}_all
    done < inlist_${line}

done < instIDlist

while read line; do
    echo "ID: " ${line}

    ls out_${line}* > outlist_${line}

    while read line2; do
	echo "cat " ${line2}
	cat ${line2} >> out_${line}_all
    done < outlist_${line}

done < instIDlist
