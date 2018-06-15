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
    iplist_concat.append(tmp[0].strip())
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

#print(len(iplist_concat))
#print(len(iplist_new))

#print(iplist_new)
#print(iplist_concat)

set_concat = set(iplist_concat)
set_new = set(iplist_new)

diff = list(set_new - set_concat)
#print(len(diff))
#print(diff)

#diff2 = set_new - set(diff)

#matched_list = []
#for concat in iplist_concat:
#    for new in iplist_new:
#        if concat == new:
#            matched_list.append(new)

#print(len(matched_list))

print("timestamp, counter, ipaddr")
counter = 0
for x in diff:
    print(str(dt.strptime(argvs[3],'%Y%m%d')).replace("-","/") + "," + str(counter) + "," + x)
    counter = counter + 1
    
