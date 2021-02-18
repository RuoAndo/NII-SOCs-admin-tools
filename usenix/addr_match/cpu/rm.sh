RMDATE=`date --date '5 day ago' +%Y%m%d`
echo $RMDATE
rm -rf *_${RMDATE}

#if [[ ! -e $RMDATE ]]; then
#  echo "OK:"$RMDATE
#fi
