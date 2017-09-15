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