import sys 
import socket, struct
from binascii import hexlify
import datetime
from datetime import datetime as dt

argvs = sys.argv
 
f = open(argvs[1])

line = f.readline()

dst = 0
src = 0
dstport = 0
srcport = 0
bts = 0

while line:
    
    try:

        tmp = line.split(",")
        dt = datetime.datetime.strptime(tmp[1], '%Y-%m-%d %H:%M:%S.%f')
        tmp[1] = (dt-datetime.datetime(1970,1,1)).total_seconds()

        #print dif
        
        tmp[7] = struct.unpack('I', socket.inet_aton(tmp[7]))[0]
        tmp[9] = struct.unpack('I', socket.inet_aton(tmp[9]))[0]

        srcport = tmp[20]
        dstport = tmp[21]
        bts = tmp[25]
        
        if tmp[0] == '':
            tmp[0] = 0

        if tmp[4] == '':
            tmp[4] = 0

        if dst == '':
            dst = 0

        if src == '':
            src = 0

        if tmp[20] == '':
            tmp[20] = 0

        if tmp[21] == '':
            tmp[21] = 0

        if tmp[25] == '':
            tmp[25] = 0

        constr = ""
        for x in tmp:
            constr = constr + str(x) + ","

        print constr.strip()


        
    except:
        pass
        
    line = f.readline()

