# iperf -s
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  4] local 192.168.1.1 port 5001 connected with 192.168.1.2 port 55700
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-10.0 sec   112 MBytes  94.1 Mbits/sec

~# iperf -c 192.168.1.1
------------------------------------------------------------
Client connecting to 192.168.1.1, TCP port 5001
TCP window size: 85.0 KByte (default)
------------------------------------------------------------
[  3] local 192.168.1.2 port 55700 connected with 192.168.1.1 port 5001

[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec   112 MBytes  94.2 Mbits/sec
