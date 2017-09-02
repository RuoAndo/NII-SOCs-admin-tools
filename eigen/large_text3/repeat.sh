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
