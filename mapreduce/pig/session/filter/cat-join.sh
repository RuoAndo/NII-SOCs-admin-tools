TESTFILE=$1

rm -rf  reduced-join-all
touch reduced-join-all

#dump-dns-joinaa-reduced
while read line; do
    fn=`readlink -f  dump-dns-$line-reduced/* | grep part`
    ary=(`echo $fn`)  
    #echo ${#ary[@]}
    for i in `seq 1 ${#ary[@]}`
    do
	wc -l ${ary[$i-1]}
	cat ${ary[$i-1]} >> reduced-join-all
    done

done < $1

