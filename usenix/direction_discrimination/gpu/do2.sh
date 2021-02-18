#./do.sh ingress_${1} | cut -d "," -f 22 | grep -v ip | grep -v directory | tr -d "\"" | uniq > list2

listname=`echo ${1} | cut -d "_" -f 2`
echo $listname
./do.sh ingress_${1} | cut -d "," -f 22 | grep -v ip | grep -v directory | tr -d "\"" | uniq > list2
./drem.pl list2 > list3
./search.sh list3 ingress_${1} | uniq  > hit-ingress_${1}
cp list3 ip-ingress_${1}

listname=`echo ${1} | cut -d "_" -f 2`
echo $listname
./do.sh egress_${1} | cut -d "," -f 22 | grep -v ip | grep -v directory | tr -d "\"" | uniq > list2
./drem.pl list2 > list3
./search.sh list3 egress_${1} | uniq  > hit-egress_${1}
cp list3 ip-egress_${1}
