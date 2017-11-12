rm -rf in_*
rm -rf out_*

while read line; do
    \cp /data1/count-session/$line .

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
    
