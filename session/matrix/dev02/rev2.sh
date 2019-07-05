./build2.sh reverse2

# trans-counts-bytes-20190518
DATE=`date -d '5 day ago' "+%Y%m%d"`
echo " trans-counts-bytes-${DATE}"

nLines=`wc -l trans-counts-bytes-${DATE} | cut -d " " -f 1`
echo $nLines

echo "transforming..."
time ./reverse2 trans-counts-bytes-${DATE} ${nLines} 

rm -rf rev.trans-counts-bytes-${DATE}
touch rev.trans-counts-bytes-${DATE}

echo "timestamp, srcIP, destIP, counts, counts_in, counst_out, bytes, bytes_in, bytes_out" > rev.trans-counts-bytes-${DATE}
echo "concatenating (appending)..."
time cat tmp2 >> rev.trans-counts-bytes-${DATE}

rm -rf  rev.trans-counts-bytes-all-current
cp rev.trans-counts-bytes-${DATE} rev.trans-counts-bytes-all-current
