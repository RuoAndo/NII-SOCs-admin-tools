while read line; do
    echo $line

    while read line2; do

	grep -a $line2 $2 > tmp

	if [ "$?" -eq 0 ]
	then
	    gr=`grep -a $line2 $2 | uniq` 
	    echo 'HIT:'$gr
	else
	    echo $line2':NOT FOUND'
	fi

    done < $line

done < $1
