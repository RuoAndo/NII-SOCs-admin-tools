if [ "$1" = "" ]
then
    echo "./do2.sh [file name]"
    exit 1
fi

./build.sh netmask5

nLines_1=100000000
nLines_2=10000000

echo "splitting..."
split -l ${nLines_1} -a 2 $1 y

ls y* > list

rm -rf rendered-all
touch rendered-all

while read line; do
    echo $line
    
    echo "splitting 2..."
    split -l ${nLines_2} $line 
    
    ls x* > list2

    while read line2; do
	echo $line2
	rm -rf rendered_$line2
	nLines_to_split=`wc -l $line2 | cut -d " " -f 1`
	./netmask5 monitoring_list2 $line2 ${nLines_to_split} &
    done < list2

    wait

    while read line2; do
	echo $line2
	cat rendered_${line2} >> rendered-all
    done < list2

done < list
