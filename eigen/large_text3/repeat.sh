<<<<<<< HEAD
./avg2.sh all2 # generates avg-all2
nl=`wc -l avg-all2 | cut -d ' ' -f1` 
./core avg-all2 $nl 4 500000 5
./cat.sh list2 # generates "all2"
python 0.py all2
python concate.py all2 avg-all2 | tee result

echo "current"
cat result
echo "previous"
cat result.bak

\cp result result.bak
=======
\cp c2 c2.bak
python fill5.py c2 | tee c3
#python fill7.py c2 | tee c3
./core c3 10 5 500000 5
./cat.sh list2 # generates "all2"
python 0.py all2 | tee nclstr
./avg2.sh all2
python concate2.py all2 avg-all2 c3 | tee c2

#python file.py c4 c3 > c2
#python 1.py all2 nclstr.bak 
#cat SSE
#\cp nclstr nclstr.bak
>>>>>>> 74b91a7d2221f9cf3b743f2ca613f4fc1374aa93
