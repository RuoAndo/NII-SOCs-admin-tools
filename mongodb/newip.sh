ls iplist-commerr-* > list-commer
head -n 5 list-commerr > list-commerr-latest

while read line; do
    echo $line
    python update-damballa.py $line
done < list-commerr-latest

ls iplist-target-* > list-target
head -n 5 list-target > list-target-latest

while read line; do
    echo $line
    python update-paloalto.py $line
done < list-target

ls iplist-attack-* > list-attack
head -n 5 list-attack > list-attack-latest

while read line; do
    echo $line
    python update-firepower.py $line
done < list-attack-latest
