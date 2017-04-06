import sys 

argvs = sys.argv
 
f = open(argvs[1])

line = f.readline() 

while line:

    if len(line) > 10:
        print line.strip()
    line = f.readline()

f.close

