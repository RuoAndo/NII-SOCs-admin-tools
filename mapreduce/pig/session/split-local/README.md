# time ./do.sh list
generates addrpair-join-$1.

<pre>
TESTFILE=$1
while read line; do
    echo $line
    hadoop fs -put $line
    ./addrpair.sh $line
    ./addrpair-join.sh $line
    ./addrpair-sid.sh $line
    ./addrpair-avg.sh $line
    ./join.sh $line
done < $1
</pre>

join.sh
<pre>
rm -rf addrpair-join-$1
hadoop fs -rmr addrpair-join-$1
pig -x local -param DIRAVG=addrpair-avg-$1 -param DIRSID=addrpair-sid-$1 -param OUTPUTDIR=addrpair-join-$1 join.pig
hadoop fs -get addrpair-join-$1 
</pre>

# ./cat.sh list
generates addrpair-join-all from addrpair-join-$1.

<pre>
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

</pre>

# ./label.sh addrpair-join-all

# ./cat-cls.sh
generates cat-cls-all

# ./cat-cat-avg.sh
generates cat-avg-all

# python 2.py cat-avg-all cat-cls-all
# python 3.py cat-avg-all cat-cls-all


