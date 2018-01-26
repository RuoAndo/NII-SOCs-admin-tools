import sys
import re
from numpy import *

def ip_to_b(addr):
    return "".join(map(lambda x: "%08d" % int(bin(int(x))[2:]), addr.split(".")))
 
def is_in_subnet(addr, subnet):
    addr_b = ip_to_b(addr)
    subnet_addr, mask = subnet.split("/")
    subnet_addr_b = ip_to_b(subnet_addr)
    mask = int(mask)
    return addr_b[:mask] == subnet_addr_b[:mask]

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 

while line:
    tmp = line.split(":")
    #print tmp[0]

    f2 = open(argvs[2])
    line2 = f2.readline() 
    while line2:

        if line2.find(tmp[0]) > -1:
            tmp2 = line2.split(",")
            #print tmp[0] + "," + line2.strip()
            
            f3 = open(argvs[3])
            line3 = f3.readline() 
            while line3:
                tmp3 = line3.split(",")
                #print tmp3[1]

                #print tmp[0] + "->" + tmp2[0]
                try:
                    if is_in_subnet(tmp2[0], tmp3[1]) == True:
                        print tmp[1].strip() + "," + "OUT," + tmp3[0] + "," + tmp2[0] + "," + line2.strip()

                    if is_in_subnet(tmp2[1], tmp3[1]) == True:
                        print tmp[1].strip() + "," + "IN," + tmp3[0] + "," + tmp2[1] + "," + line2.strip()
                        
                except:
                    #print "error"
                    pass

                line3 = f3.readline() 

        line2 = f2.readline() 

    line = f.readline()

