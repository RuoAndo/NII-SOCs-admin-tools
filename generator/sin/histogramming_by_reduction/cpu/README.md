# Reduction with concurrent hashmap (Intel TBB)

<pre>
# ./build.sh rand_gen
# ./rand_gen 100000
# rm -rf data/*
# split -l 10000 random_data.txt 
# mv x* ./data/
# time ./multi_measure data/
# head -n 5 tmp-counts 
</pre>

<pre>
$ time ./a.out 2000000000

real    1018m42.861s
user    962m25.721s
sys     56m4.835s
</pre>
