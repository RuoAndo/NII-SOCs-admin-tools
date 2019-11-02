#if [ "$1" = "" ]
#then
#    echo "usage: ./repeat [FILE_NAME]"
#    exit 1
#fi

DATE=`date --date '4 day ago' +%Y%m%d` 
echo $DATE

ls -alh /data1/${DATE}/all-org
echo "copying..."
cp /data1/${DATE}/all-org .

nProcs=24
nLines=`wc -l all-org | cut -d " " -f 1`
LINES_TO_SPLIT=`expr $nLines / $nProcs`

echo ${LINES_TO_SPLIT} 

rm -rf *_ingress
rm -rf *_egress

echo "removing and splitting..."
rm -rf x*
split -l ${LINES_TO_SPLIT} -a 2 all-org x

ls x* > list

split -n 8 list list.

./build.sh netmask8

############# 1 ##############

SECONDS=0
while read line; do
    echo $line
    comstr="./netmask8 list-us-east-1 ${line} ${LINES_TO_SPLIT} &"
    echo $comstr
    eval $comstr
done < list.aa

wait

time=$SECONDS
echo $time" sec"

#############

############# 2 ##############

SECONDS=0
while read line; do
    echo $line
    comstr="./netmask8 list-us-east-1 ${line} ${LINES_TO_SPLIT} &"
    echo $comstr
    eval $comstr
done < list.ab

wait

time=$SECONDS
echo $time" sec"

#############

############# 3 ##############

SECONDS=0
while read line; do
    echo $line
    comstr="./netmask8 list-us-east-1 ${line} ${LINES_TO_SPLIT} &"
    echo $comstr
    eval $comstr
done < list.ac

wait

time=$SECONDS
echo $time" sec"
 
############# 3 END ####


############# 4 ##############

SECONDS=0
while read line; do
    echo $line
    comstr="./netmask8 list-us-east-1 ${line} ${LINES_TO_SPLIT} &"
    echo $comstr
    eval $comstr
done < list.ad

wait

time=$SECONDS
echo $time" sec"
 
############# 4 END ####


############# 5 ##############

SECONDS=0
while read line; do
    echo $line
    comstr="./netmask8 list-us-east-1 ${line} ${LINES_TO_SPLIT} &"
    echo $comstr
    eval $comstr
done < list.ae

wait

time=$SECONDS
echo $time" sec"
 
############# 5 END ####

############# 6 ##############

SECONDS=0
while read line; do
    echo $line
    comstr="./netmask8 list-us-east-1 ${line} ${LINES_TO_SPLIT} &"
    echo $comstr
    eval $comstr
done < list.af

wait

time=$SECONDS
echo $time" sec"
 
############# 6 END ####


############# 7 ##############

SECONDS=0
while read line; do
    echo $line
    comstr="./netmask8 list-us-east-1 ${line} ${LINES_TO_SPLIT} &"
    echo $comstr
    eval $comstr
done < list.ag

wait

time=$SECONDS
echo $time" sec"
 
############# 7 END ####

############# 8 ##############

SECONDS=0
while read line; do
    echo $line
    comstr="./netmask8 list-us-east-1 ${line} ${LINES_TO_SPLIT} &"
    echo $comstr
    eval $comstr
done < list.ah

wait

time=$SECONDS
echo $time" sec"
 
############# 8 END ####

### cat all (ingress)
 
ls *_ingress > list_ingress

rm -rf all_ingress
touch all_ingress

SECONDS=0

while read line; do
    #echo "writing"$line"..."
    cat $line >> all_ingress
done < list_ingress

time=$SECONDS
echo $time" sec"

### cat all (egress)

ls *_egress > list_egress

rm -rf all_egress
touch all_egress

rm -rf all_ingress
touch all_ingress

SECONDS=0

while read line; do
    #echo "writing "$line"..."
    cat $line >> all_egress
done < list_egress

while read line; do
    #echo "writing "$line"..."
    cat $line >> all_ingress
done < list_ingress

time=$SECONDS
echo $time" sec"

wc -l all_egress
wc -l all_ingress

mv all_egress AWS_us-east-1_all_egress_${DATE}
mv all_ingress AWS_us-east-1_all_ingress_${DATE}

scp AWS_us-east-1_all_ingress_${DATE} 192.168.72.6:/mnt/sdc/splunk_mzn/ingress_us-east-1/
scp AWS_us-east-1_all_egress_${DATE} 192.168.72.6:/mnt/sdc/splunk_mzn/egress_us-east-1/

rm -rf x*
