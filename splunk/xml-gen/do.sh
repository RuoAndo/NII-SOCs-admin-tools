echo "<dashboard>"
echo "<label>test3</label>"

while read line; do
    #echo $line
    python 6.py $line
done < $1

echo "</dashboard>"
