TESTFILE=$1

rm -rf  dnsdump-join-all
touch dnsdump-join-all
while read line; do
    fn=`readlink -f  dump-dns-$line/* | grep part`
    ary=(`echo $fn`)  
    #echo ${#ary[@]}
    for i in `seq 1 ${#ary[@]}`
    do
	wc -l ${ary[$i-1]}
	cat ${ary[$i-1]} >> dnsdump-join-all
    done

done < $1

