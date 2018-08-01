cat $1 | awk -F',' '{print $6","$9}' | tr -d '"'
