RMDATE=`date --date '7 day ago' +%Y%m%d`
echo $RMDATE
rm -rf *_${RMDATE}

#if [[ ! -e $RMDATE ]]; then
#  echo "OK:"$RMDATE
#fi

rm -rf ingress_osakadai/*_${RMDATE}
rm -rf egress_osakadai/*_${RMDATE}

rm -rf ingress_kobedai/*_${RMDATE}
rm -rf egress_kobedai/*_${RMDATE}

rm -rf ingress_okayamadai/*_${RMDATE}
rm -rf egress_okayamadai/*_${RMDATE}
