ls *detailed* | grep iplist | grep -v lg > tmp-detailed

while read line; do
    echo $line
    \cp $line ./detailed/
done < tmp-detailed
