./avg2.sh all2

python fill4.py c > c2
./sort.pl c2 > c3
#LC=`wc -l c | cut -d " " -f1`
#comstr="./first c $LC 4 500000 5"
#eval $comstr
./first c3 10 4 500000 5
./cat.sh list2
python 0.py all2 | tee nclstr
python 1.py all2 nclstr.bak
cat SSE
\cp nclstr nclstr.bak
