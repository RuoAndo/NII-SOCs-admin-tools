./build2.sh reverse

DATE=`date -d '5 day ago' "+%Y%m%d"`
echo "trans-src-dst-all-${DATE}"

nLines=`wc -l trans-src-dst-all-${DATE} | cut -d " " -f 1`
echo $nLines

echo "transforming..."
time ./reverse trans-src-dst-all-${DATE} ${nLines} 

rm -rf rev.trans-src-dst-all-${DATE}
touch rev.trans-src-dst-all-${DATE}

echo "timestamp, srcIP, destIP" > rev.trans-src-dst-all-${DATE}
echo "concatenating..."
time cat tmp >> rev.trans-src-dst-all-${DATE}

