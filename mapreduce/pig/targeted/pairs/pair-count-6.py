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
                str2 = str(j)
                #str3 = str2.replace("."," ").replace(":"," ")
                #print "DEBUG" + str3
                #print str2
                matchedList = re.findall(pattern,str2)

                cnt = matchedList[-1]
                
                #print matchedList
                matchedList.pop()
                #print matchedList

                mlt = " ".join(matchedList)
                #print "mlt:" + mlt

                tmpstr = tmpstr + "," + mlt + "," + cnt + ","
                
                counter = 0
                for l in count_dict:
                    # print "l:" + l

                    flag = 0
                    found_counter = 0
                    for mat in matchedList:
                        #print "mat:" + mat + ":" + l
                        if l.find(mat) == -1:
                            flag = 1 
                            found_counter = found_counter + 1

                    if flag == 0:
                        print "found_counter:" + str(found_counter) 
                        hittmpstr = str(count_dict_list[counter])#.split(",")
                        tmpstr = tmpstr + "," +  "*" + hittmpstr#[-1].replace(")","").lstrip()
                        
                    counter = counter + 1
                            

    print tmpstr.replace("'","").replace(",,",",")
    
    line = f.readline() 

