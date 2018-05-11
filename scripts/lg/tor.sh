# ./apt.sh 20180417 20180421

COUNT=$1

rm -rf tmp-list
touch tmp-list

while [ $COUNT -le $2 ]; do
    ./listup.pl | grep detailed | grep -v "iplist/" | grep -v system_tags | grep $COUNT >> tmp-list
    COUNT=`expr $COUNT + 1` # COUNT をインクリメント
done

#cat tmp-list

rm -rf tags-$1-$2
touch tags-$1-$2

COUNT=0
COUNT2=0
while read line; do
    #echo $line
    if [ `echo $line | grep 'delta'` ] ; then
	d=`echo $line | cut -d "-" -f 3`
    else
	d=`echo $line | cut -d "-" -f 4`
    fi
    gr=`python readjson.py $line $d | grep Tor`
    #echo $gr

    if [ -n "$gr" ]; then
	echo " " 

	if [ `echo $line | grep 'delta'` ] ; then
	    echo $line | sed -e 's/[^0-9]//g' | cut -c 1-8
	    dfn=`echo $line | cut -d "/" -f 3`
	    fn="./delta/"${dfn}
	    echo $fn
	    python readjson2.py ${fn} Tor
	    COUNT2=`expr $COUNT2 + 1` # COUNT をインクリメント
	else
	    #echo $line
	    echo $line | sed -e 's/[^0-9]//g' | cut -c 3-10
	    python readjson2.py $line Tor
	    COUNT2=`expr $COUNT2 + 1` # COUNT をインクリメント
	fi

    fi

    COUNT=`expr $COUNT + 1` # COUNT をインクリメント
done < tmp-list
  
echo $COUNT2

#cat tags-$1-$2
#./drem.pl tags-$1-$2 > tags-$1-$2-drem
#cat tags-$1-$2-drem
