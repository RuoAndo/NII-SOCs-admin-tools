date=$(date -d '2 day ago' "+%Y%m%d")
echo $date

#/mnt/data/Usenix_LISA19/direction_discrimination/cpu/20191108_egress_sinet

mkdir sinet_ingress
mkdir sinet_egress

./build.sh multi_measure
echo "copying..."
cp -r /root/Usenix_LISA19/direction_discrimination/cpu/sinet_ingress_${date} .

./multi_measure ./sinet_ingress_${date}

echo "timestamp, count" > tmp
cat tmp-counts >> tmp
cp tmp ./sinet_ingress/${date}_ingress_sinet
rm -rf tmp
rm -rf ./sinet_ingress/tmp

rm -rf /root/Usenix_LISA19/direction_discrimination/cpu/sinet_ingress_${date}
rm -rf sinet_ingress_${date}

#######

echo "copying..."
cp -r /root/Usenix_LISA19/direction_discrimination/cpu/sinet_egress_${date} .

./multi_measure ./sinet_egress_${date} .

echo "timestamp, count" > tmp
cat tmp-counts >> tmp
cp tmp ./sinet_egress/${date}_egress_sinet 
rm -rf tmp
rm -rf ./sinet_egress/tmp

#rm -rf ${date}

rm -rf /root/Usenix_LISA19/direction_discrimination/cpu/sinet_egress_${date}
rm -rf sinet_egress_${date}
