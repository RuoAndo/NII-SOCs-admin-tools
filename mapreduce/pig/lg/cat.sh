TESTFILE=$1

rm -rf addrpair-join-all
touch addrpair-join-all
while read line; do
    fn=`readlink -f addrpair-join-$line/* | grep part`
    ary=(`echo $fn`)  
    #echo ${#ary[@]}
    for i in `seq 1 ${#ary[@]}`
    do
	wc -l ${ary[$i-1]}
	cat ${ary[$i-1]} >> addrpair-join-all
    done

done < $1

