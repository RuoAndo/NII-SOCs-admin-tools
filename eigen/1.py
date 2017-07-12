# python 1.py tools/libxl/libxl.c libxl 372

import sys 

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

while line:

    tmp = line.split(",")
    print tmp[1] + "," + tmp[2]

    #packed_ip_addr = socket.inet_aton(ip_address)
    #unpacked_ip_addr = socket.inet_ntoa(packed_ip_addr)
    #print "Packed: %s, Unpacked: %s" % (hexlify(packed_ip_addr), unpacked_ip_addr)
    
    line = f.readline()
    
