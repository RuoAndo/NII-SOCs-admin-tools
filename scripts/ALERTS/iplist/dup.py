import sys                                                                                                               
import re                                                                                                               
argvs = sys.argv                                                                                                         
argc = len(argvs)                                                                                                       

f = open(argvs[1])                                                                                                      
line = f.readline()

iplist_lg = []                                                                                                     
while line:                                                                                                            
    tmp = line.split(":")                                                                                                
    #print(tmp[0])
    iplist_lg.append(tmp[0])
    line = f.readline()                                                                                                 
f.close()

#print(iplist_lg)

f = open(argvs[2])                                                                                                      
line = f.readline()

iplist_all = []                                                                                                     
while line:                                                                                                            
    #tmp = line.split(",")                                                                                              
    #print(tmp[0])
    iplist_all.append(line.strip())
    line = f.readline()                                                                                                 
f.close()

#print(iplist_all)

set_lg = set(iplist_lg)
set_all = set(iplist_all)

diff = (set_lg - set_all)
print(len(diff))
#print(diff)
