TESTFILE=$1

rm -rf sip-join-all
touch sip-join-all
while read line; do
    fn=`readlink -f sip-$line/* | grep part`
    ary=(`echo $fn`)  
    #echo ${#ary[@]}
    for i in `seq 1 ${#ary[@]}`
    do
	wc -l ${ary[$i-1]}
	cat ${ary[$i-1]} >> sip-join-all
    done

done < $1

