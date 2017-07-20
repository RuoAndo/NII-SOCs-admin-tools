# python 1.py tools/libxl/libxl.c libxl 372

import sys 
import collections

import re
re_addr = re.compile("((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))")
re_num = re.compile("'[0-9]+'")

#pattern = r"[a-xA-Z0-9_:.() ]+"
pattern = r"[a-zA-Z0-9]+"

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

anames = []

while line:
    tmp = line.split(",")
    #print tmp
    anames.append(tmp[25])
    line = f.readline()

count_dict = collections.Counter(anames)
print count_dict
count_dict_list = count_dict.items()

#print count_dict["MAIL: User Login Brute Force Attempt(40007)"] 


f.close()

##################

f = open(argvs[2])

line = f.readline() 

alerts = []

while line:

    tmp = line.split(",")

    tmpstr = ""
    for i in tmp:
        m = re_addr.search(str(i))
        if m is not None:
            tmpstr = tmpstr + str(i).replace(")","").strip() + ","

    #print tmpstr        
            
    count_dict2 = collections.Counter(tmp)
    cdm = count_dict2.most_common(5)
    #print cdm
    
    for j in cdm:
        m3 = re_num.search(str(j))
        if m3 is None:

            m2 = re_addr.search(str(j))
            if m2 is None:
                str2 = str(j)#.replace(")"," ").replace(")"," ").replace(":"," ").replace("."," ")
                #print str2
                matchedList = re.findall(pattern,str2)

                cnt = matchedList[-1]
                
                #print matchedList
                matchedList.pop()
                #print matchedList

                mlt = " ".join(matchedList)
                #print "mlt:" + mlt

                tmpstr = tmpstr + "," + mlt + "," + cnt + ","
                
                kensaku1 = matchedList[0]
                kensaku2 = matchedList[1]
                #kensaku3 = matchedList[2]

                counter = 0
                for l in count_dict:
                    #print "l:" + l + ":kensaku" + kensaku

                    flag = 0
                    for mat in matchedList:
                        if mat not in l:
                            flag = 1

                    if flag == 0:
                        hittmpstr = str(count_dict_list[counter]).split(",")
                        tmpstr = tmpstr + "," +  "*" + hittmpstr[-1].replace(")","").lstrip()
                        
                    counter = counter + 1
                            

    print tmpstr.replace("'","").replace(",,",",")
    
    line = f.readline() 

