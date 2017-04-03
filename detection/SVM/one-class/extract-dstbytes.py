import sys 
import socket, struct
from binascii import hexlify

argvs = sys.argv
 
f = open(argvs[1])

line = f.readline() 

while line:

    try:
        tmp = line.split(",")
        
        dst = struct.unpack('I', socket.inet_aton(tmp[7]))[0]
        src = struct.unpack('I', socket.inet_aton(tmp[9]))[0]

        if tmp[0] == '':
            tmp[0] = 0

        if tmp[4] == '':
            tmp[4] = 0

        if dst == '':
            dst = 0

        if src == '':
            src = 0

        if tmp[25] == '':
            bt = 0
        else:
            bt = tmp[25]
            
        print str(dst) + "," + bt 

    except:
        pass
        
    line = f.readline()

