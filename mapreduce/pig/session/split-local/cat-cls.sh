TESTFILE=$1

rm -rf cat-cls-*

a=0
while [ $a -ne 5 ]
do
    fn=`readlink -f tmp-cls-$a/* | grep part`
    ary=(`echo $fn`)  
    #echo ${#ary[@]}

    touch cat-cls-$a
    
    for i in `seq 1 ${#ary[@]}`
    do
	echo ${ary[$i-1]}
	#wc -l ${ary[$i-1]}
	cat ${ary[$i-1]} >> cat-cls-$a
    done

    a=`expr $a + 1`
done 

