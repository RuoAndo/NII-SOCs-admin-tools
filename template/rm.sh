RMDATE=`date --date '4 day ago' +%Y%m%d`
echo $RMDATE
rm -rf $RMDATE

if [[ ! -e ./$RMDATE ]]; then
  echo "OK:"$RMDATE
fi

RMDATE=`date --date '3 day ago' +%Y%m%d`
echo $RMDATE

while read line; do
    echo egress_${line}_${RMDATE}
    
    rm -rf egress_${line}_${RMDATE}
    rm -rf egress_${line}/*_${RMDATE}
    rm -rf ingress_${line}_${RMDATE}
    rm -rf ingress_${line}/*_${RMDATE}

done < university-list
