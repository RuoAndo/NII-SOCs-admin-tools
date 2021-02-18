./do.sh ingress_${1} | cut -d "," -f 22 | grep -v ip | tr -d "\"" | uniq > list2
./search.sh list2 list-${1} | uniq 
./search.sh list2 list-${1} | uniq | wc -l
