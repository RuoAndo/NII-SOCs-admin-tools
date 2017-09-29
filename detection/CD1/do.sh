rm -rf in_*
rm -rf out_*

while read line; do
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

    cd ..
    
done < $1

#cd ..

while read line; do
    echo "ID: " ${line}
    
    ls in_* | grep ${line} > inlist_${line}
    rm -rf ${line}-all
    touch ${line}-all

    # in_10034_20170920
    
    while read line2; do
	echo "cat " ${line2}
	cat ${line2} >> ${line}-all
    done < inlist_${line}
	
done < $2
    
