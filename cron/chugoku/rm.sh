RMDATE=`date --date '7 day ago' +%Y%m%d`
echo $RMDATE
rm -rf *_${RMDATE}

#if [[ ! -e $RMDATE ]]; then
#  echo "OK:"$RMDATE
#fi

rm -rf ingress_hiroshimadai/*_${RMDATE}
rm -rf egress_hiroshimadai/*_${RMDATE}

rm -rf ingress_okayamadai/*_${RMDATE}
rm -rf ingress_okayamadai/*_${RMDATE}
