./build2.sh reverse

STARTDATE=`date -d '19 day ago' "+%Y%m%d"`
ENDDATE=`date -d '4 day ago' "+%Y%m%d"`

CURRENTDATE=$STARTDATE

#rm -rf tmp-inward-tmp
#touch tmp-inward-tmp
#trans-src-dst-all-20190601

rm -rf rev.trans-src-dst-all-${CURRENTDATE}
touch rev.trans-src-dst-all-${CURRENTDATE}

echo "timestamp, srcIP, destIP" > rev.trans-src-dst-all-${CURRENTDATE}

while [ 1 ] ; do
        echo trans-src-dst-all-${CURRENTDATE}

	nLines=`wc -l trans-src-dst-all-${CURRENTDATE} | cut -d " " -f 1`
	echo $nLines

	echo "transforming..."
	time ./reverse trans-src-dst-all-${CURRENTDATE} ${nLines} 

	echo "concatenating..."
	time cat tmp >> rev.trans-src-dst-all-${CURRENTDATE}

        if [ $CURRENTDATE = $ENDDATE ] ; then
                break
        fi

        CURRENTDATE=`date -d "$CURRENTDATE 1day" "+%Y%m%d"`
done

#rm -rf tmp-inward-14
#touch tmp-inward-14

#echo "timestamp, counted, bytes" > tmp-inward-14
#grep -v timestamp tmp-inward-tmp >> tmp-inward-14
