RMDATE=`date --date '8 day ago' +%Y%m%d`
echo $RMDATE
rm -rf ./egress_${1}/*_${RMDATE}
rm -rf ./ingress_${1}/*_${RMDATE}


