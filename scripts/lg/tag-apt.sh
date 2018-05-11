if [ "$1" = "" ]
then
    echo "no argument: ./mail.sh startDate endDate"
fi

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

rm -rf tmp-tag-apt
touch tmp-tag-apt

COUNT=0
COUNT2=0
while read line; do
    #echo $line
    if [ `echo $line | grep 'delta'` ] ; then
	d=`echo $line | cut -d "-" -f 3`
    else
	d=`echo $line | cut -d "-" -f 4`
    fi
    gr=`python readjson.py $line $d | grep "APT"`
    echo $gr

    if [ -n "$gr" ]; then
	echo " " 

	if [ `echo $line | grep 'delta'` ] ; then
	    echo " " | tee -a tmp-tag-apt
	    echo $line | sed -e 's/[^0-9]//g' | cut -c 1-8 | tee -a tmp-tag-apt
	    dfn=`echo $line | cut -d "/" -f 3`
	    fn="./delta/"${dfn}
	    echo $fn
	    python readjson2.py ${fn} "APT" | tee -a tmp-tag-apt
	    COUNT2=`expr $COUNT2 + 1` # COUNT をインクリメント
	else
	    echo " " | tee -a tmp-tag-apt
	    echo $line | sed -e 's/[^0-9]//g' | cut -c 3-10 | tee -a tmp-tag-apt
	    python readjson2.py $line "APT" | tee -a tmp-tag-apt
	    COUNT2=`expr $COUNT2 + 1` # COUNT をインクリメント
	fi

    fi

    COUNT=`expr $COUNT + 1` # COUNT をインクリメント
done < tmp-list

rm -rf mail-APT-$1-$2
  
cat tmp-tag-apt > mail-APT-$1-$2

echo "############"
cat tmp-tag-apt

echo $COUNT2" days" | tee -a mail-APT-$1-$2

ntag=`grep "\[" tmp-tag-apt | wc -l`
echo $ntag "tags"

grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' tmp-tag-apt >> mail-APT-$1-$2
gr=`grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' tmp-tag-apt | wc -l | tee -a mail-APT-$1-$2`
echo $gr " IP addresses"

grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' tmp-tag-apt > tmp-ipaddress-apt-$1-$2
./drem.pl tmp-ipaddress-apt-$1-$2 > tmp-ipaddress-apt-$1-$2-drem
nIP=`wc -l tmp-ipaddress-apt-$1-$2-drem | cut -d " " -f 1`                                                              
echo $nIP" addresses"                                                                                                  
cat tmp-ipaddress-apt-$1-$2-drem

