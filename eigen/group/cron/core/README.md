<pre>
0 2 * * * cd /mnt/sdc/GET_DATA; ./1.sh >> GET_DATA.log 2>> GET_DATA.log
0 5 * * * cd /mnt/sdc/GET_DATA/OUTPUT/reduce; ./traverse.sh
0 4 * * * cd /mnt/sdc/count-session; ./session.sh >> count_session.log 2>> count_session.log
0 6 * * * cd /mnt/sdc/GET_DATA/OUTPUT/reduce/traversed; /bin/bash -l ./reduce10.sh >> analog.log 2>> analog.log
0 7 * * * cd /mnt/sdc/GET_DATA/OUTPUT; ./test.sh
0 8 * * * cd /mnt/sdc/GET_DATA/OUTPUT; ./scp-72.3_0.sh
0 9 * * * cd /mnt/sdc/GET_DATA/OUTPUT; ./scp-72.4_1.sh
0 10 * * * cd /mnt/sdc/GET_DATA/OUTPUT; ./scp-72.6_2.sh
0 11 * * * cd /mnt/sdc/GET_DATA/OUTPUT; ./scp-72.6_all.sh
1 0 * * * cd /mnt/sdc/reduced; ./reduce.sh
</pre>
