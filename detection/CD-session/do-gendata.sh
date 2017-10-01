rm -rf in_*
rm -rf out_*

cPWD=`pwd`
echo $PWD

while read line; do
    echo $line

    cd $cPWD
    cd $line

    rm -rf *list*

    rm -rf in_*
    rm -rf out_*

    rm -rf *.py .
    rm -rf *.pl .
    rm -rf *.sh .
    rm -rf instlist

    \cp $cPWD/gendata/*.py .
    \cp $cPWD/gendata/*.pl .
    \cp $cPWD/gendata/*.sh .
    cp $cPWD/instlist . 

    \cp $cPWD/*.py .
    \cp $cPWD/*.pl .
    \cp $cPWD/*.sh .
    
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

    cd $cPWD
    
done < $1

cd $cPWD

while read line; do
    echo "ID: " ${line}
    
    ls in_* | grep ${line} > inlist_${line}
    rm -rf in_${line}_all
    touch in_${line}_all

    # in_10034_20170920
    
    while read line2; do
	echo "cat " ${line2}
	cat ${line2} >> in_${line}_all
    done < inlist_${line}

    #####
    
    ls out_* | grep ${line} > outlist_${line}
    rm -rf out_${line}_all
    touch out_${line}_all
    
    while read line2; do
	echo "cat " ${line2}
	cat ${line2} >> out_${line}_all
    done < outlist_${line}
	
done < $2
    
ls in*all
ls out*all
