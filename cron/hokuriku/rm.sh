RMDATE=`date --date '7 day ago' +%Y%m%d`
echo $RMDATE
rm -rf *_${RMDATE}

#if [[ ! -e $RMDATE ]]; then
#  echo "OK:"$RMDATE
#fi

rm -rf ingress_niigatadai/*_${RMDATE}
rm -rf egress_niigatadai/*_${RMDATE}

rm -rf ingress_jaist/*_${RMDATE}
rm -rf egress_jaist/*_${RMDATE}

rm -rf ingress_toyamadai/*_${RMDATE}
rm -rf egress_toyamadai/*_${RMDATE}

