ls *detailed* | grep iplist | grep "h-" > tmp-detailed-all

rm -rf tmp-tag-all
touch tmp-tag-all

while read line; do
    #echo $line
    python readjson.py $line | tee -a tmp-tag-all
done < tmp-detailed-all
