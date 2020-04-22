RMDATE=`date --date '7 day ago' +%Y%m%d`
echo $RMDATE
rm -rf *_${RMDATE}
rm -rf $RMDATE

rm -rf ingress_ehimedai/*_${RMDATE}
rm -rf egress_ehimedai/*_${RMDATE}

rm -rf ingress_tokushimadai/*_${RMDATE}
rm -rf egress_tokushimadai/*_${RMDATE}

rm -rf ingress_kagawadai/*_${RMDATE}
rm -rf egress_kagawadai/*_${RMDATE}

rm -rf ingress_kouchi/*_${RMDATE}
rm -rf egress_kouchi/*_${RMDATE}

#if [[ ! -e $RMDATE ]]; then
#  echo "OK:"$RMDATE
#fi
