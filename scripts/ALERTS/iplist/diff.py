import sys                                                  
import re                                                   
from datetime import datetime as dt                                                           

argvs = sys.argv                                                                                                         
argc = len(argvs)                                                                                                       

f = open(argvs[1])                                                                                                      
line = f.readline()

iplist_concat = []                                                                                                     
while line:                                                                                                            
    tmp = line.split(":")                                                                                                
    iplist_concat.append(tmp[0])
    line = f.readline()                                                                                                 
f.close()

f = open(argvs[2])                                                                                                      
line = f.readline()

iplist_new = []                                                                                                     
while line:                                                                                                            
    #tmp = line.split(",")                                                                                              
    #print(tmp[0])
    iplist_new.append(line.strip())
    line = f.readline()                                                                                                 
f.close()

set_concat = set(iplist_concat)
set_new = set(iplist_new)

diff = (set_new - set_concat)
#print(len(diff))
#print(diff)

print("timestamp, counter, ipaddr")

counter = 0
for x in diff:

   print(str(dt.strptime(argvs[3],'%Y%m%d')).replace("-","/") + "," + str(counter) + "," + x)
   counter = counter + 1
    
