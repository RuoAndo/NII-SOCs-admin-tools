DATE=`date --date '4 day ago' +%Y%m%d` 
echo $DATE
start_time=`date +%s`

ls -alh /mnt/data/${DATE}/all-org

echo "copying..."
cp /mnt/data/${DATE}/all-org .

./build.sh netmask5

nLines_1=100000000
nLines_2=500000

echo "removing and splitting..."
rm -rf y*
split -l ${nLines_1} -a 2 all-org y

ls y* > list

rm -rf rendered_inward-all
touch rendered_outward_-all

rm -rf directed_msec-all
touch directed_msec-all

while read line; do
    echo $line
    
    echo "splitting 2..."
    rm -rf x*
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
	cat rendered_inward_${line2} >> rendered_inward-all
	cat rendered_outward_${line2} >> rendered_outward-all
    done < list2

    while read line2; do
	echo $line2
	cat directed_msec_inward_${line2} >> directed_msec_inward-all
    done < list2

    while read line2; do
	echo $line2
	cat directed_msec_outward_${line2} >> directed_msec_outward-all
    done < list2

done < list

cp rendered_inward-all rendered_inward-all_${DATE}
cp rendered_outward-all rendered_outward-all_${DATE}
#scp rendered-all_${DATE} 192.168.72.5:/mnt/sdc/session-directed/fsv02/
#scp rendered-all_${DATE} 192.168.72.6:/mnt/sdc/session-directed/fsv02/
#scp rendered-all_${DATE} 192.168.76.210:/mnt/sdc/session-directed/fsv02/


cp directed_msec_inward-all directed_msec_inward-all_${DATE}
#scp directed_msec_inward-all_${DATE} 192.168.72.5:/mnt/sdc/session-directed/fsv02/
#scp directed_msec_inward-all_${DATE} 192.168.72.6:/mnt/sdc/session-directed/fsv02/
#scp directed_msec_inward-all_${DATE} 192.168.76.203:/root/session-directed/fsv02/
#scp directed_msec_inward-all_${DATE} 192.168.76.210:/mnt/data/session-directed/fsv02/

cp directed_msec_outward-all directed_msec_outward-all_${DATE}
#scp directed_msec_outward-all_${DATE} 192.168.72.5:/mnt/sdc/session-directed/fsv02/
#scp directed_msec_outward-all_${DATE} 192.168.72.6:/mnt/sdc/session-directed/fsv02/
#scp directed_msec_outward-all_${DATE} 192.168.76.203:/root/session-directed/fsv02/
#scp directed_msec_outward-all_${DATE} 192.168.76.210:/mnt/data/session-directed/fsv02/

wc -l all-org
wc -l rendered-all_${DATE}

#rm -rf rendered*
#rm -rf directed*

rm -rf directed_msec_inward_x*
rm -rf directed_msec_outward_x*
rm -rf rendered_inward_x*
rm -rf rendered_outward_x*

end_time=`date +%s`
time=$((end_time - start_time))
echo "time elapsed:"$time"@"${DATE}
