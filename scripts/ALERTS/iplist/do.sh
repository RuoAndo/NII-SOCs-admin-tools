ls iplist-commerr-* > list-commerr

while read line; do
    echo $line
    python update-damballa.py $line
done < list-commerr

ls iplist-target-* > list-target

while read line; do
    echo $line
    python update-paloalto.py $line
done < list-target

ls iplist-attack-* > list-attack

while read line; do
    echo $line
    python update-firepower.py $line
done < list-attack
