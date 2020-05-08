str=`sed -n 6p $1`
echo $str

ARR=(${str//,/ })

COUNT=0
for S in "${ARR[@]}"; do 

    COUNT=`expr $COUNT + 1`
    # echo "$S"; 
    
    if [ $COUNT -eq 2 ] ; then
	concat=$concat" "$2

    elif [ $COUNT -eq 6 ] ; then
	tmp=`echo $S | tr -d "\""`
	concat=$concat" "$tmp"_"$3

    elif [ $COUNT -eq 8 ] ; then
	tmp=`echo $S | cut -d "." -f 1`
	concat=$concat" "$tmp"_"$3".xml"
       
    else
	concat=$concat" "$S

    fi
   
done

echo $concat
