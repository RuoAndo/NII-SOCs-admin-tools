import sys 
import collections
import commands

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

ips = []

while line:
    #print line
    tmp = line.split(",")
    ips.append(tmp[0])
    ips.append(tmp[1])
    line = f.readline()

#print ips
ips_uniq = list(set(ips)) 
print ips_uniq

for i in ips_uniq:
    if len(i) > 0:
        comstr = "python slmbr.py " + i
        check = commands.getoutput(comstr)
        
        if len(check) > 0:
            print comstr
            print check
        else:
            print comstr.strip() + "-"+ "No info."
