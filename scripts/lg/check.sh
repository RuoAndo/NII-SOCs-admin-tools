ls *detailed* | grep "h-" > list-detailed
ls iplist-* | grep "h-" | grep -v tag | grep -v lg | grep -v detailed | grep -v reduced > list-iplist

./sort-list.pl list-iplist | grep app > list-iplist-sorted-app
./sort-list.pl list-iplist | grep cp > list-iplist-sorted-cp
./sort-list.pl list-iplist | grep reduced > list-iplist-sorted-reduced

./drem.pl list-iplist-sorted-cp > list-iplist-sorted-cp-drem
./drem.pl list-iplist-sorted-app > list-iplist-sorted-app-drem
./drem.pl list-iplist-sorted-reduced > list-iplist-sorted-reduced-drem

./sort-list.pl list-detailed | grep app > list-detailed-sorted-app
./sort-list.pl list-detailed | grep cp > list-detailed-sorted-cp
./sort-list.pl list-detailed | grep reduced > list-detailed-sorted-reduced

#cat list-iplist-sorted-cp-drem
#cat list-detailed-sorted-cp

while read line; do
    echo $line
    grep $line list-detailed-sorted-app

    if [ "$?" -eq 0 ]
    then
	:
    else
	echo 'MISS:'$line
fi
done < list-iplist-sorted-app-drem

while read line; do
    echo $line
    grep $line list-detailed-sorted-cp

    if [ "$?" -eq 0 ]
    then
	:
    else
	echo 'MISS:'$line
fi
done < list-iplist-sorted-cp-drem

while read line; do
    echo $line
    grep $line list-detailed-sorted-reduced

    if [ "$?" -eq 0 ]
    then
	:
    else
	echo 'MISS:'$line
fi
done < list-iplist-sorted-reduced-drem
