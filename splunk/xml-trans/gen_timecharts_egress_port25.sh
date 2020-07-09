#!/bin/bash

rm -rf timecharts_all_egress_port25.xml
grep -v dashboard timecharts_template_egress_port25.xml  | grep -v label > org.xml 

echo "<dashboard>" >> timecharts_all_egress_port25.xml
echo "<label>SINET timecharts (egress/outgoing) to PORT25</label>" >> timecharts_all_egress_port25.xml

while read row; do
  column1=`echo ${row} | cut -d , -f 1`
  column2=`echo ${row} | cut -d , -f 2 | tr -d "\""`
  column3=`echo ${row} | cut -d , -f 3 | tr -d "\""`

  #echo $column1
  #echo $column2
  #echo $column3

  column3_1=`echo ${column3} | cut -d = -f 2`
  #echo ${column3_1}

  ./trans.sh org.xml $column2 $column2 $column3_1 $column1 >> timecharts_all_egress_port25.xml

done < $1

#echo "</label>" >> all-test.xml
echo "</dashboard>" >> timecharts_all_egress_port25.xml

