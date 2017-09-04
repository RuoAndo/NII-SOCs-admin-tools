rm -rf dump-dns
touch dump-dns
while read line; do
    ./dns.sh $line
done < $1
