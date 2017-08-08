# clustering with data decomposition 

setting thread number according to the number of split file.

<pre>
 12#include <eigen3/Eigen/Core>                                               
 13#include <eigen3/Eigen/SVD>                                                
 14                                                                           
 15#define THREAD_NUM 10                                                      
 16                                                                           
 17using namespace Eigen;                                                     
 18using namespace std; 
</pre>

10 split files with 500,000 lines 

<pre>
# more list                                            
outaa
outab
outac
outad
outae
outaf
outag
outah
outai
outaj

# wc -l outaa                                          
500000 outaa
</pre>

concatenate.

<pre>
# ./cat.sh list

# wc -l all
5000000 all
</pre>


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
