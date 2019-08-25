RMDATE=`date --date '7 day ago' +%Y%m%d`                                                                                
echo $RMDATE                                                                                              
                
# 20190805_outward
# directed_msec_outward-all_20190805

rm -rf $RMDATE_outward
rm -rf $RMDATE_inward

rm -rf directed_msec_outward-all_${RMDATE}
rm -rf directed_msec_inward-all_${RMDATE}
