\cp c2 c2.bak

#python fill5.py c2 | tee c3
#python fill7.py c2 | tee c3

nl=`wc -l c2 | cut -d ' ' -f1` 
echo "LN:" $nl
./core c2 $nl 5 500000 5
./cat.sh list2 # generates "all2"
python 0.py all2 | tee nclstr
./avg2.sh all2
\cp avg-all2 c2

python comp.py c2.bak c2

<<<<<<< HEAD
#python concate2.py all2 avg-all2 c3 | tee c2

=======
>>>>>>> 1da744fa630923bd6090e89eb44dc3c88b9f50a8
#python file.py c4 c3 > c2
#python 1.py all2 nclstr.bak 
#cat SSE
#\cp nclstr nclstr.bak
