import sys 

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])
line = f.readline() 

ID = []
Name = []

while line:
    tmp = line.split("\t")
    ID.append(tmp[0])
    Name.append(tmp[1])

    line = f.readline()

f.close()

#print ID

ID_in = {}
ID_out = {}

for i in ID:
    ID_in[i] = 0

for i in ID:
    ID_out[i] = 0

f = open(argvs[2])
line = f.readline() 

while line:
    tmp = line.split(",")

    # SRC is not EMPTY: outward
    if int(tmp[0]) != 0:
        for i in ID:
            if int(str(tmp[0]))==int(i):
                ID_in[i] = int(tmp[2])

    # DST is not EMPTY: inward
    if int(tmp[1]) != 0:
        for i in ID:
            if int(str(tmp[1]))==int(i):
                ID_out[i] = int(tmp[2])

    line = f.readline() 

f.close()

#print ID_in
for i in ID_in:
    tmpstr = str(ID_in[i])
    f2 = open("in_" + i, 'a') 
    f2.write(tmpstr + "\n") 
    f2.close()

#print ID_out
for i in ID_out:
    tmpstr = str(ID_out[i])
    f2 = open("out_" + i, 'a') 
    f2.write(tmpstr + "\n") 
    f2.close() 

        




            
            

