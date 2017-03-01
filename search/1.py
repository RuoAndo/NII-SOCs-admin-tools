# python 1.py tools/libxl/libxl.c libxl 372

import sys 

import socket, struct
from binascii import hexlify

src = 0
dst = 0

if __name__ == '__main__':

    argvs = sys.argv  
    argc = len(argvs) 

    f = open(argvs[1])
    
    line = f.readline() 

    alts = []
    ips = []
    
    while line:
        tmp = line.split("\t")

        counter = 0
        for i in tmp:
            #print i + ":" + str(counter)

            if counter == 32:
                alts.append(tmp[32])
            counter = counter + 1

        line = f.readline() 

    alts_uniq = list(set(alts)) 
        
    print alts_uniq
        
    f.close()

######

    f2 = open(argvs[1])
    
    line = f2.readline() 

    while line:
        tmp = line.split("\t")
        
        counter = 0
        for i in tmp:
            #print i + ":" + str(counter)

            if counter == 32:
                alts.append(tmp[32])
                #print tmp[32]

                counter2 = 0
                for a in alts_uniq:
                    if a == tmp[32]:

                        try:
                            #ip = tmp[7]
                            dst = struct.unpack('I', socket.inet_aton(tmp[7]))[0]
            
                            #ip = tmp[8]
                            src = struct.unpack('I', socket.inet_aton(tmp[8]))[0]

                        except:
                            pass
                            
                        print str(dst) + ":" + str(src) + ":" + str(counter2)
                            
                    counter2 = counter2 + 1
                        
            counter = counter + 1
        
        line = f2.readline() 
    
    

