rm -rf 20*
rm -rf *egress
rm -rf *ingress

date=$(date -d '1 day ago' "+%Y%m%d")
echo $date
REGION_NAME=$1
LIST_NAME=list-${1}

#chmod 400 ${LIST_NAME}

if [ "$1" = "" ]
then
    echo "usage: ./multi_measure.sh [REGION_NAME]"
    exit 1
fi

BASEDIR="/home/flare/blaze/"
du -h ${BASEDIR}${date}
echo "copying..."
time cp -r ${BASEDIR}${date} .

./build-traverse.sh discernGPU_tuple
time ./discernGPU_tuple $date ${LIST_NAME}

rm -rf *ingress
rm -rf *egress

rm -rf list-region
rm -rf list-region-uniq

while read line; do
    str=`echo $line | cut -d "," -f 3`
    #echo $str >> list-region
    #echo $str 
    mkdir ${str}_ingress
    mkdir ${str}_egress
done < $LIST_NAME

#uniq list-region > list-region-uniq

sed  '/^$/d' $LIST_NAME 

while read line; do
    #str=`echo $line | cut -d "," -f 3`
    #echo $line

    #sed  '/^$/d' $LIST_NAME 
    ls ${date} | grep ${line} | grep ingress | grep -v root > list-ingress
    #sed  '/^$/d' $LIST_NAME 
    
    while read line2; do
	#ls -alh ${date}/$line2
	#echo "copying "$line2" to "${line}_ingress/${line2}_${date}
	cp ${date}/$line2 ${line}_ingress/${line2}_${date}
    done < list-ingress

    #sed  '/^$/d' $LIST_NAME 
    ls ${date} | grep ${line} | grep egress | grep -v root > list-egress
    #sed  '/^$/d' $LIST_NAME 
    
    while read line3; do
	#ls -alh ${date}/$line3
	#echo "copying "$line3" to "${line}_egress/${line3}_${date}
	cp ${date}/$line3 ${line}_egress/${line3}_${date}
    done < list-egress
    
done < ${LIST_NAME}

sed  '/^$/d' $LIST_NAME 
#start_time=`date +%s`

du -h ${BASEDIR}${date}
