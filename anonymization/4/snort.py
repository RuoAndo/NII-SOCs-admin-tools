import sys 
import socket, struct
from binascii import hexlify
import datetime
from datetime import datetime as dt

argvs = sys.argv
 
f = open(argvs[1])

line = f.readline()

while line:

    try:
        tmp = line.split(",")

        #print tmp[1]
        dt = datetime.datetime.strptime(tmp[1], '%Y-%m-%d %H:%M:%S.%f')
        dif = (dt-datetime.datetime(1970,1,1)).total_seconds()

        counter = 0
        for x in tmp:
            if tmp[counter] == '':
                tmp[counter] = 0

            counter = counter + 1

        comstr = str(tmp[0]) + "," + str(tmp[2]) + "," + str(tmp[3]) + "," + str(tmp[10]) + "," + str(tmp[14]) 

        print comstr

    except:
        pass


    
    line = f.readline()

