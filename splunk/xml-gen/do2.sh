echo "<dashboard>"
echo "<label>test4</label>"

while read line; do
    #echo $line
    python 7.py $line
done < $1

echo "</dashboard>"
