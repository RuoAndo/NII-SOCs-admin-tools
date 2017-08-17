# spliting files.

<pre>
# split -l 500000 r out

* 50,000 - 1,000,000 could be limit of eigen.

# ls
data.c   outaa  outac  outae  outag  outai  outak  outam  outao  outaq  outas  outau  outaw  outay  outba
data.sh  outab  outad  outaf  outah  outaj  outal  outan  outap  outar  outat  outav  outax  outaz  

</pre>

# translating files

<pre>
# ./rename.sh list

# ls
0  10  12  14  16  18  2   21  23  25  3  5  7  9       
1  11  13  15  17  19  20  22  24  26  4  6  8 
</pre>


<pre>

 12#include <eigen3/Eigen/Core>
 13#include <eigen3/Eigen/SVD>
 14
 15#define THREAD_NUM 26
 16
 17using namespace Eigen;
 18using namespace std;

</pre>
 