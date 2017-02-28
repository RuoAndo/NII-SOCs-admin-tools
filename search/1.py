# python 1.py tools/libxl/libxl.c libxl 372

import sys 

import socket, struct
from binascii import hexlify

def convert_ip4_address(ip_address):
    packed_ip_addr = socket.inet_aton(ip_address)
    unpacked_ip_addr = socket.inet_ntoa(packed_ip_addr)
    print "Packed: %s, Unpacked: %s" % (hexlify(packed_ip_addr), unpacked_ip_addr)
                    
if __name__ == '__main__':

    argvs = sys.argv  
    argc = len(argvs) 

    f = open(argvs[1])

    line = f.readline() 

    alts = []
    ips = []
    
    while line:
        tmp = line.split("\t")

        try:
            ip = tmp[7]
            dst = struct.unpack('I', socket.inet_aton(ip))[0]
            #print dst
            
            ip = tmp[8]
            src = struct.unpack('I', socket.inet_aton(ip))[0]

            #print str(dst) + ":" + str(src)

        except:
            pass

        counter = 0
        for i in tmp:
            #print i + ":" + str(counter)

            if counter == 32:
                alts.append(tmp[32])
            counter = counter + 1

        line = f.readline() 

    alts_uniq = list(set(alts)) 
        
    print alts_uniq
        
    #for i in vuls:
    #    print i
        
    

