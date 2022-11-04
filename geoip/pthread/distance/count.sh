grep distance log |  cut -d ":" -f 4 | sort | uniq -c | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{ print $2}' > IP

grep distance log |  cut -d ":" -f 4 | sort | uniq -c | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{ print $1}' > COUNT

paste IP COUNT -d ","
