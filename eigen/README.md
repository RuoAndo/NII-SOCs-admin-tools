# reading CSV

<pre>
filename rows cols

./a.out sample 5 4 data 1000 6
</pre>

<pre>
 ./a.out sample 5 4 data-10 10 6

# time ./a.out sample 5 4 cat-cls-all 8852374 6 > tmp

real    3m31.332s
user    3m22.132s
sys     0m9.168s
</pre>

<pre>

# time python trans.py cat-cls-all > cat-cls-all-trans   

real    14m54.170s
user    14m41.412s
sys     0m12.263s

# ./a.out cat-avg-all 5 4 cat-cls-all-trans 273253468 6
</pre>