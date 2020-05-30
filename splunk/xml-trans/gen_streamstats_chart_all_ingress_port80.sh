#SINET_10_Hokkaido_Daigaku,"/mnt/data2/sinet/hokkaido/Usenix_LISA19/direction_discrimination/gpu/ingress_hokkaidodai/*",host="h-gpu04"

#!/bin/bash

rm -rf streamstats_chart_all_ingress_port80.xml
grep -v dashboard streamstats_template_ingress_port80.xml | grep -v label > org.xml 

echo "<dashboard>" >> streamstats_chart_all_ingress_port80.xml
echo "<label>SINET treamstats charts (ingress)</label>" >> streamstats_chart_all_ingress_port80.xml

while read row; do
  column1=`echo ${row} | cut -d , -f 1`
  column2=`echo ${row} | cut -d , -f 2 | tr -d "\""`
  column3=`echo ${row} | cut -d , -f 3 | tr -d "\""`

  #echo $column1
  #echo $column2
  #echo $column3

  column3_1=`echo ${column3} | cut -d = -f 2`
  #echo ${column3_1}

  ./trans.sh org.xml $column2 $column2 $column3_1 $column1 >> streamstats_chart_all_ingress_port80.xml

done < $1

#echo "</label>" >> all-test.xml
echo "</dashboard>" >> streamstats_chart_all_ingress_port80.xml

