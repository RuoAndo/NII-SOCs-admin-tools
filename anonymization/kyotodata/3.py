import sys 
import re

argvs = sys.argv
 
f = open(argvs[1])

line = f.readline() 

session = []
while line:

    tmp = re.split('\,', line)
    session.append(tmp[15])
    line = f.readline()
    
f.close

session_uniq = list(set(session))

counter = 0
dict = {}

for x in session_uniq:
    dict.update({counter : x})
    counter = counter + 1

#print dict

f2 = open(argvs[1])
line2 = f2.readline()

while line2:
    tmp = re.split(',', line2)
    #print tmp
    for x,y in dict.items():
        if y == tmp[15]:
            tmp[15] = x

            comstr = ""
            for z in tmp:
                comstr = comstr + str(z) + ","
            print comstr.strip()
                
            #tmpstr = ",".join(v for k, v in dict.items())
    line2 = f2.readline()

            

        



