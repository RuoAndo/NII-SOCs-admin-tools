import sys 

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])
line = f.readline() 

instIDlist = []
instNamelist = []

while line:
    tmp = line.split("\t")
    #print tmp

    instIDlist.append(tmp[0])
    instNamelist.append(tmp[1].strip())
    
    line = f.readline()

#print instIDlist
#print instNamelist

f.close()

f = open(argvs[2])
line = f.readline() 

flist = []

while line:
    flist.append(line.strip())
    line = f.readline()

#print flist

f.close()

tmpseries = []

for i in flist:

    f = open(i)
    line = f.readline() 

    counter = 0
    while line:
        #for j in inst
        tmp = line.split(",")
        #print tmp
        
        if len(tmp[1]) > 0 and int(tmp[1]) == 10180:
            #print "HIT"
            tmpseries.append(tmp[2].strip())
        
        if counter == 1:
            #print "break"
            break
        counter = counter + 1
        
        line = f.readline() 

print tmpseries
