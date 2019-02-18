#-rw-r--r--. 1 root root  11G  2月  5 09:48 directed_msec_outward-all_20190201
#-rw-r--r--. 1 root root  26G  1月 22 21:29 rendered-all_20190118

RMDATE=`date --date '7 day ago' +%Y%m%d`                                                                                
echo $RMDATE                                                                                              
                
rm -rf rendered-all_$RMDATE

