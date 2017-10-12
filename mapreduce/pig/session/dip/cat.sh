TESTFILE=$1

rm -rf dip-join-all
touch dip-join-all
while read line; do
    fn=`readlink -f dip-$line/* | grep part`
    ary=(`echo $fn`)  
    #echo ${#ary[@]}
    for i in `seq 1 ${#ary[@]}`
    do
	wc -l ${ary[$i-1]}
	cat ${ary[$i-1]} >> dip-join-all
    done

done < $1

