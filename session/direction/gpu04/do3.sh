DATE=`date --date '4 day ago' +%Y%m%d` 
echo $DATE
ls -alh /mnt/data2/${DATE}/all-org

echo "copying..."
cp /mnt/data2/${DATE}/all-org .

./build.sh netmask5

nLines_1=100000000
nLines_2=10000000

echo "splitting..."
split -l ${nLines_1} -a 2 all-org y

ls y* > list

rm -rf rendered-all
touch rendered-all

rm -rf directed_msec-all
touch directed_msec-all

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

    while read line2; do
	echo $line2
	cat directed_msec_${line2} >> directed_msec-all
    done < list2

done < list

cp rendered-all rendered-all_${DATE}
scp rendered-all_${DATE} 192.168.72.5:/mnt/sdc/session-directed/fsv02/
scp rendered-all_${DATE} 192.168.72.5:/mnt/sdc/session-directed/fsv03/
scp rendered-all_${DATE} 192.168.72.5:/mnt/sdc/session-directed/gpu04/
scp rendered-all_${DATE} 192.168.72.6:/mnt/sdc/session-directed/fsv02/
scp rendered-all_${DATE} 192.168.72.6:/mnt/sdc/session-directed/fsv03/
scp rendered-all_${DATE} 192.168.72.6:/mnt/sdc/session-directed/gpu04/

cp directed_msec-all directed_msec-all_${DATE}
scp directed_msec-all_${DATE} 192.168.72.5:/mnt/sdc/session-directed/fsv02/
scp directed_msec-all_${DATE} 192.168.72.5:/mnt/sdc/session-directed/fsv03/
scp directed_msec-all_${DATE} 192.168.72.5:/mnt/sdc/session-directed/gpu04/
scp directed_msec-all_${DATE} 192.168.72.6:/mnt/sdc/session-directed/fsv02/
scp directed_msec-all_${DATE} 192.168.72.6:/mnt/sdc/session-directed/fsv03/
scp directed_msec-all_${DATE} 192.168.72.6:/mnt/sdc/session-directed/gpu04/

wc -l all-org
wc -l rendered-all_${DATE}
rm -rf rendered-all_${DATE}
rm -rf directed_msec-all_${DATE}
