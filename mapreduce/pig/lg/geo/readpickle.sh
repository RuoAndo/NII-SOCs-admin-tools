rm -rf HC_ip_tag_report_"$1".pkl
ls HC*$1*pkl > datelist

#rm -rf $1-all
#touch $1-all
while read line; do
    #echo $line
    cat $line >> HC_ip_tag_report_"$1".pkl
done < datelist

#python readpickle.py NII_ip_tag_report_2017-09-09.pkl NII_ip_tag_additions_2017-09-09.csv

#comstr=`echo "python readpickle.py HC_ip_tag_report_"$1".pkl NII_ip_tag_additions_"$1".csv"`
comstr=`echo "python readpickle.py HC_ip_tag_report_"$1".pkl"`
#echo $comstr
eval ${comstr}