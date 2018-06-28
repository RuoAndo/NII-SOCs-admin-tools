ls iplist-attack-* > list-attack
#tail -n 5 list-attack > list-attack-latest
#cat list-attack-latest

while read line; do
    echo $line
    python update-firepower.py $line
done < list-attack #-latest
