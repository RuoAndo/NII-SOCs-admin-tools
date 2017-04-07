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
        
        tmp2 = struct.unpack('I', socket.inet_aton(tmp[7]))[0]
        tmp[7] = tmp2
        
        tmp2 = struct.unpack('I', socket.inet_aton(tmp[9]))[0]
        tmp[9] = tmp2
        
        counter = 0
        for x in tmp:
            if x =='':
                tmp[counter] = 0
            counter = counter +1


            
        constr = ""
        for x in tmp:
            constr = constr + str(x).strip() + ","

        if len(constr.strip()) > 10:
            print constr.strip().rstrip(",")
        
    except:
        pass
        
    line = f.readline()

