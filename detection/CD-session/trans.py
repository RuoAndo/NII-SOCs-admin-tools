import sys 

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

while line:
    
    try:
        
        tmp = line.split(",")
    
        if(tmp[0]==""):
            tmp[0] = 0

        if(tmp[1]==""):
            tmp[1] = 0

        if(tmp[2]==""):
            tmp[2] = 0
        
        comstr =""

        for x in tmp:
            comstr += str(x).strip() + ","

        print comstr 

    except:
        pass

    line = f.readline()


