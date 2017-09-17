# step0: converting data
<pre>
# split -l 500000 out all
# ls out* > list
# more list
outaa
:
:
outat

# time ./rename.sh list
now processing  outaa : 0  ...
now processing  outab : 1  ...
now processing  outat : 19  ...

real    0m57.583s
user    0m50.116s
sys     0m0.788s
</pre>

# step1: init label
<pre>
# ./build.sh rand-labeling
# time ./rand-labeling 500000 5
thread ID: 4 - done.
thread ID: 2 - done.
thread ID: 13 - done.
thread ID: 6 - done.
thread ID: 1 - done.
thread ID: 14 - done.

real    1m6.811s
user    3m7.980s
sys     0m11.260s
</pre>

# step1.5: counting data per cluster 1
<pre>
# ls *.labeled > list-labeled
#  ./cat-labeled.sh list-labeled 
# python 0.py all-labeled 
CLUSTER0,1001317
CLUSTER1,1000283
CLUSTER2,999402
CLUSTER3,1002177
CLUSTER4,1000838
CLUSTER5,995949
CLUSTER6,999997
CLUSTER7,999324
CLUSTER8,1001701
CLUSTER9,999012
</pre>

# step2: calculating centroid on *.labeled
<pre>
string fname = std::to_string(targ->id) + ".labeled";

# ./avg 500000 6
924.294 11727.4 2.50272
1047.97 14205.2 2.51709
1325.77 24361.1 2.55667
1147.44 11051.4 2.51789
1102.12 10560.6 2.52627
1222.46 21160.3 2.53161
1087.52 18003.2 2.52412
741.566 11188.1 2.52434
695.171 11771.5 2.52395
1437.14 17321.1 2.49817
</pre>

# step3: relabeling data on *.labeled, calculating norms (distance).
<pre>
string fname = std::to_string(targ->id) + ".labeled";

# time ./relabel centroid 10 3 500000 6
real    2m23.588s
user    6m55.716s
sys     0m12.752s
</pre>

# step3.5 cantatenating and counting data per cluster 2
<pre>
# ./cat-relabeled.sh list-relabeled 
# python 0.py all-relabeled | tee tmp-all-relabled
CLUSTER0,2080538
CLUSTER1,256980
CLUSTER2,602390
CLUSTER3,1051014
CLUSTER4,1673200
CLUSTER5,36556
CLUSTER6,352981
CLUSTER7,215307
CLUSTER8,414409
CLUSTER9,3316625
</pre>

# step4 copying *.relabed to *.labeled and back to step2.
<pre>
# ./rename2.sh list-relabeled 

for line in `cat ${1}`
do
    cut=`echo $line | cut -d "." -f1`
    echo "now relabeling " $line ":" $cut".labeled" " ..."
    \cp $line $cut.labeled
done

# python result.py tmp-all-relabled centroid
</pre>

# misc
<pre>
 2274  split -l 500000 all-10000000 out
 2276  ls -alh out* > list
 2277  wc -l list

(dev1_3.5.1) root@dell:~/nii-cyber-security-admin/eigen/large_text4# pyenv versions
  system
  2.7
  2.7/envs/dev1_2.7
  3.5.1
  3.5.1/envs/dev1_3.5.1
  dev1_2.7
* dev1_3.5.1 (set by /home/flare/.python-version)

(dev1_3.5.1) root@dell:~/nii-cyber-security-admin/eigen/large_text4# pyenv global 2.7
(dev1_3.5.1) root@dell:~/nii-cyber-security-admin/eigen/large_text4# pyenv local dev1_2.7
</pre>

