#!/bin/bash

rm -rf streamstats_chart_all_egress.xml
grep -v dashboard streamstats_template_egress.xml | grep -v label > org.xml 

echo "<dashboard>" >> streamstats_chart_all_egress.xml
echo "<label>SINET treamstats charts (egress)</label>" >> streamstats_chart_all_egress.xml

while read row; do
  column1=`echo ${row} | cut -d , -f 1`
  column2=`echo ${row} | cut -d , -f 2 | tr -d "\""`
  column3=`echo ${row} | cut -d , -f 3 | tr -d "\""`

  #echo $column1
  #echo $column2
  #echo $column3

  column3_1=`echo ${column3} | cut -d = -f 2`
  #echo ${column3_1}

  ./trans.sh org.xml $column2 $column2 $column3_1 $column1 >> streamstats_chart_all_egress.xml

done < $1

#echo "</label>" >> all-test.xml
echo "</dashboard>" >> streamstats_chart_all_egress.xml

