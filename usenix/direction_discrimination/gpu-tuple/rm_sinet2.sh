RMDATE=`date --date '30 day ago' +%Y%m%d`
echo $RMDATE
rm -rf *_${RMDATE}
rm -rf $RMDATE

#if [[ ! -e $RMDATE ]]; then
#  echo "OK:"$RMDATE
#fi
