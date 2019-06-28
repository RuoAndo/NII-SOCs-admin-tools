LINES_TO_SPLIT=20000000

DATE=`date --date '4 day ago' +%Y%m%d` 
echo $DATE
start_time=`date +%s`

ls -alh /data1/${DATE}/all-org

echo "copying..."
cp /data1/${DATE}/all-org .

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

rm -rf ${DATE}_inward
mkdir ${DATE}_inward
split -l ${LINES_TO_SPLIT} rendered_inward-all_${DATE} inward.
mv inward.* ${DATE}_inward/

rm -rf ${DATE}_outward
mkdir ${DATE}_outward
split -l ${LINES_TO_SPLIT} rendered_outward-all_${DATE} outward.
mv outward.* ${DATE}_outward/

scp -r ${DATE}_inward/ 192.168.76.210:/mnt/data/session_directed/fsv02/
scp -r ${DATE}_outward/ 192.168.76.210:/mnt/data/session_directed/fsv02/

scp -r ${DATE}_inward/ 192.168.76.203:/root/session_directed/fsv02/
scp -r ${DATE}_outward/ 192.168.76.203:/root/session_directed/fsv02/

#scp rendered_inward-all_${DATE} 192.168.76.210:/mnt/data/session_directed/fsv02
#scp rendered_inward-all_${DATE} 192.168.76.210:/mnt/data/session_directed/fsv02

cp directed_msec_inward-all directed_msec_inward-all_${DATE}
cp directed_msec_outward-all directed_msec_outward-all_${DATE}

wc -l all-org
wc -l rendered_inward-all_${DATE}
wc -l rendered_outward-all_${DATE}

DATE=`date --date '6 day ago' +%Y%m%d`

rm -rf ${DATE}_outward
rm -rf ${DATE}_inward

rm -rf rendered_inward-all_${DATE}
rm -rf rendered_outward-all_${DATE}

rm -rf directed_msec_inward-all_${DATE}
rm -rf directed_msec_outward-all_${DATE}

rm -rf directed_msec_inward_x*
rm -rf directed_msec_outward_x*
rm -rf rendered_inward_x*
rm -rf rendered_outward_x*

end_time=`date +%s`
time=$((end_time - start_time))
echo "time elapsed:"$time"@"${DATE}
