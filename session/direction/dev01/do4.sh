./build.sh netmask6

LINES_TO_SPLIT=20000000

DATE=`date --date '4 day ago' +%Y%m%d` 
echo $DATE
start_time=`date +%s`

ls -alh /root/${DATE}/all-org

echo "copying..."
cp /root/${DATE}/all-org .

nLines_1=100000000
nLines_2=500000

echo "removing and splitting..."
rm -rf y*
split -l ${nLines_1} -a 2 all-org y

ls y* > list

rm -rf rendered_inward-all
touch rendered_inward-all

rm -rf rendered_outward-all
touch rendered_outward-all

rm -rf directed_msec_inward-all
touch directed_msec_inward-all

rm -rf directed_msec_outward-all
touch directed_msec_outward-all

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
	./netmask6 monitoring_list2 $line2 ${nLines_to_split} &
    done < list2

    wait

    # rm -rf rendered_inward-all
    # touch rendered_inward-all

    # rm -rf rendered_outward-all
    # touch rendered_outward-all
    
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

cp directed_msec_inward-all directed_msec_inward-all_${DATE}
cp directed_msec_outward-all directed_msec_outward-all_${DATE}

wc -l all-org
wc -l rendered_inward-all_${DATE}
wc -l rendered_outward-all_${DATE}

rm -rf x*
rm -rf y*

scp -r ${DATE}_inward 192.168.72.6:/mnt/sdc/splunk_direction/dev01/
scp -r ${DATE}_outward 192.168.72.6:/mnt/sdc/splunk_direction/dev01/

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
