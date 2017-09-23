TESTFILE=$1

rm -rf fanout-all
touch fanout-all
while read line; do
    fn=`readlink -f dump_fanout2_$line/* | grep part`
    ary=(`echo $fn`)  
    #echo ${#ary[@]}
    for i in `seq 1 ${#ary[@]}`
    do
	wc -l ${ary[$i-1]}
	cat ${ary[$i-1]} >> fanout-all
    done

done < $1

