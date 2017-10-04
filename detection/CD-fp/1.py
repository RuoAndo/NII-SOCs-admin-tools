import sys 
import os

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])
line = f.readline() 

fList = []
while line:
    fList.append(line.strip())
    line = f.readline() 

f.close()
    
#print fList

wList = []
for i in fList:
    
    f = open(i)
    line = f.readline()

    while line:
        tmp = line.split(",")
        wList.append(tmp[0])
        line = f.readline()

    f.close()
        
#print wList
wList_uniq = list(set(wList)) 
print wList_uniq

try:
    os.remove("warnlist")
except:
    pass

# generating list
for i in wList_uniq:
    f = open("warnlist", 'a') 
    if len(i) > 5:
        f.write(str(i) + "\n") 
    f.close()

counter = 0
for i in wList_uniq:
    fname= "fp-" + str(counter)

    try:
        os.remove(fname)
    except:
        pass
    
    counter = counter + 1
    
for j in fList:

    f = open(j)
    line = f.readline() 
    
    while line:
        tmp = line.split(",")

        fpairfile = "pair"
        os.remove(fpairfile)
        
        constr=""
        counter = 0 
        for i in wList_uniq:
            fname= "fp-" + str(counter)
            
            if str(i) == str(tmp[0]):
                constr = constr + tmp[1].strip() + ","

                f2 = open(fname, 'a') 
                f2.write(tmp[1]) 
                f2.close()

            else:
                constr = constr + "0" + ","

                f2 = open(fname, 'a') 
                f2.write("0\n") 
                f2.close()

            f2 = open(fpairfile, 'a') 
            f2.write(str(counter) + "," + str(i) + "\n") 
            f2.close()
                
            counter = counter + 1
                
        print constr
        line = f.readline() 

    f.close()

