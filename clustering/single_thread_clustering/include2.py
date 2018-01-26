import sys
import re
from numpy import *

argvs = sys.argv
argc = len(argvs)

def ip_to_b(addr):
    return "".join(map(lambda x: "%08d" % int(bin(int(x))[2:]), addr.split(".")))
 
def is_in_subnet(addr, subnet):
    addr_b = ip_to_b(addr)
    subnet_addr, mask = subnet.split("/")
    subnet_addr_b = ip_to_b(subnet_addr)
    mask = int(mask)
    return addr_b[:mask] == subnet_addr_b[:mask]

f = open(argvs[1])
line = f.readline() 

counter = 0

while line:
    #tmp = re.split('[\s+]', line) #=> ['a', 'c', 'ef', 'hi']
    tmp = line.split(",")

    f2 = open(argvs[2])
    line2 = f2.readline() 

    while line2:
        tmp2 = line2.split(",")
        try:
            #print "TEST:" + tmp[0] + "," + tmp2[1] + "," + str(len(tmp2[1]))
            
            if is_in_subnet(tmp[0], tmp2[1]) == True:
                print str(counter) + "," + "OUT:" + tmp[0] + "," + tmp[1] + "," + tmp[2] + "," + tmp[3] + "," + tmp[4] + "," + tmp[5].strip() + "," + tmp2[1] + "," + tmp2[0]

            if is_in_subnet(tmp[1], tmp2[1]) == True:
                print str(counter) + "," + "IN:" + tmp[0] + "," + tmp[1] + "," + tmp[2] + "," + tmp[3] + "," + tmp[4] + "," + tmp[5].strip() + "," + tmp2[1] + "," + tmp2[0]
            
        except:
            pass

        line2 = f2.readline() 

    counter = counter + 1
        
    f2.close()

    #print tmp[0]
    #print tmp[1]
    line = f.readline()
f.close()
