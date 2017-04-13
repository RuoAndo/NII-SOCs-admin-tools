import sys 
import re

argvs = sys.argv
 
f = open(argvs[1])

line = f.readline() 

session = []
while line:

    tmp = re.split('\t+', line)
    session.append(tmp[13])
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
    tmp = re.split('\t+', line2)
    #print tmp
    for x,y in dict.items():
        if y == tmp[13]:
            tmp[13] = x

            comstr = ""

            for z in tmp:
                comstr = comstr + str(z) + ","

            if line2.find(",") == -1:
                print comstr
                
            #tmpstr = ",".join(v for k, v in dict.items())
    line2 = f2.readline()

            

        



