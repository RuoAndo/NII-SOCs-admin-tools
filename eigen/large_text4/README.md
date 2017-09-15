<pre>
# time ./rand-labeling 500000 5
thread ID: 4 - done.
thread ID: 2 - done.
thread ID: 13 - done.
thread ID: 17 - done.
thread ID: 10 - done.
thread ID: 16 - done.
thread ID: 12 - done.
thread ID: 9 - done.
thread ID: 18 - done.
thread ID: 19 - done.
thread ID: 5 - done.
thread ID: 3 - done.
thread ID: 11 - done.
thread ID: 7 - done.
thread ID: 8 - done.
thread ID: 0 - done.
thread ID: 15 - done.
thread ID: 6 - done.
thread ID: 1 - done.
thread ID: 14 - done.

real    1m6.811s
user    3m7.980s
sys     0m11.260s
</pre>

<pre>
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

