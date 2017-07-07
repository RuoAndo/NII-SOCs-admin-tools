TESTFILE=$1

rm -rf cat-avg-all
touch cat-avg-all

    fn=`readlink -f tmp-avg/* | grep part`
    ary=(`echo $fn`)  
    #echo ${#ary[@]}

    #touch cat-cls-$a
    
    for i in `seq 1 ${#ary[@]}`
    do
	#echo ${ary[$i-1]}
	#wc -l ${ary[$i-1]}
	cat ${ary[$i-1]} >> cat-avg-all
    done

more cat-avg-all
