# clustering with large file.

# spliting files.

<pre>
# split -l 500000 r out

* 50,000 - 1,000,000 could be limit of eigen.

# ls
data.c   outaa  outac  outae  outag  outai  outak  outam  outao  outaq  outas  outau  outaw  outay  outba
data.sh  outab  outad  outaf  outah  outaj  outal  outan  outap  outar  outat  outav  outax  outaz  

</pre>

# translating files (appending thread id).

<pre>
# ./rename.sh list

# ls
0  10  12  14  16  18  2   21  23  25  3  5  7  9       
1  11  13  15  17  19  20  22  24  26  4  6  8 
</pre>

# modifying the number of threads.

<pre>

 12#include <eigen3/Eigen/Core>
 13#include <eigen3/Eigen/SVD>
 14
 15#define THREAD_NUM 26
 16
 17using namespace Eigen;
 18using namespace std;

</pre>
 
<pre>

重心の修正

 1402  ./do.sh outaa
 1406  ./centroid c 10 5  > c2
 1409  python split.py c2 > c3

修正した重心でラベル振り直し

 1414  time ./distance c3 10 5 0.para-clean 500000 6 > tmp-r
 1417  python split.py tmp-r > tmp-r.csv
 1419  ./reavg.sh tmp-r.csv 

0になっているクラスタを埋める

  # ./centroid2 c3 10 5 tmp-r.csv-avg-clean 10 5 > new-centroid
  # python split.py new-centroid > new-centroid.csv 

ラベルの振り直し

  #time ./distance new-centroid.csv 10 5 0.para-clean 500000 6 > tmp-r 
  #python 1.py tmp-r.csv

</pre>