import sys 

argvs = sys.argv
 
f = open(argvs[1])

line = f.readline() 

while line:

    try:
        tmp = line.split(",")
        print tmp[2] + " " + "1:" + tmp[0] + " 2:" + tmp[1]

    except:
        pass
        
    line = f.readline()

f.close

