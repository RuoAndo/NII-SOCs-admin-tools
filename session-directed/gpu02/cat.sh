STARTDATE=$1
ENDDATE=$2

rm -rf outward-all
touch outward-all

CURRENTDATE=$STARTDATE
while [ 1 ] ; do

    # 処理
    echo $CURRENTDATE
    # directed_msec_outward-all_20190120
    cat directed_msec_outward-all_${CURRENTDATE} >> outward-all
    
    if [ $CURRENTDATE = $ENDDATE ] ; then
	break
    fi

    CURRENTDATE=`date -d "$CURRENTDATE 1day" "+%Y%m%d"`
done
