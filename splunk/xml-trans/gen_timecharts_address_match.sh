#!/bin/bash

rm -rf timecharts_address_match.xml
grep -v dashboard template_address_match.xml  | grep -v label > org.xml 

echo "<dashboard>" timecharts_address_match.xml >> timecharts_address_match.xml
echo "<label>SINET timecharts address match</label>" >> timecharts_address_match.xml

while read row; do
  column1=`echo ${row} | cut -d , -f 1`
  column2=`echo ${row} | cut -d , -f 2 | tr -d "\""`
  column3=`echo ${row} | cut -d , -f 3 | tr -d "\""`

  #echo $column1
  #echo $column2
  #echo $column3

  column3_1=`echo ${column3} | cut -d = -f 2`
  #echo ${column3_1}

  ./trans.sh org.xml $column2 $column2 $column3_1 $column1 >> timecharts_address_match.xml

done < $1

#echo "</label>" >> all-test.xml
echo "</dashboard>" >> timecharts_address_match.xml

