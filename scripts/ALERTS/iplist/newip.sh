ls iplist-commerr-* > list-commerr
#tail -n 5 list-commerr > list-commerr-latest
#cat list-commerr-latest

while read line; do
    echo $line
    /root/.pyenv/shims/python update-damballa.py $line
done < list-commerr #-latest

ls iplist-target-* > list-target
#tail -n 5 list-target > list-target-latest
#cat list-target-latest

while read line; do
    echo $line
    /root/.pyenv/shims/python update-paloalto.py $line
done < list-target #-latest

ls iplist-attack-* > list-attack
#tail -n 5 list-attack > list-attack-latest
#cat list-attack-latest

while read line; do
    echo $line
    /root/.pyenv/shims/python update-firepower.py $line
done < list-attack #-latest
