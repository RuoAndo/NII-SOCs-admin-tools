shuf -n 10 random_data.txt | cut -d "," -f 5 | tr -d "\"" > tmp-shuf

while read line; do
    echo $line",32"
done < tmp-shuf

