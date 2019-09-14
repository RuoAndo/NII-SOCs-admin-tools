grep ip_prefix ip-ranges.json  | cut -d ":" -f 2 | tr -d "\"" | tr -d " " | tr -d "," | sed -e "s/\//,/g" > amazon_list 
