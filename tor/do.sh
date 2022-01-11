wget https://www.wivern.com/security20170414.html

rm -rf tmp
while read line; do
grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' $line >> tmp
done < security20170414.html

rm -rf tmp2
while read line; do
echo $line",32" >> tmp2 
done < tmp 

head -n 500 tmp2 > tor-list
