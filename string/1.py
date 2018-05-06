# -*- coding: utf-8 -*-

import sys 
import random
source_str = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])
line = f.readline() 

iplist = []
while line:
    #tmp = line.split(",")
    iplist.append(line)
    line = f.readline()

f = open(argvs[2])
line = f.readline() 

count_0 = 0
count_1 = 0

counter_all = 0
while line:

    tmp = line.split(",")

    flag = 0
    flag_write = 0
    for x in iplist:

        try:
        
            if x.strip() == tmp[0] and len(tmp[2]) != 0:

                flag = 1

            elif x.strip() == tmp[1] and len(tmp[2]) != 0:

                flag = 1

        except:
            pass

    try:
        if flag == 1 and len(tmp[2]) != 0:
            constr = ""
            for x in tmp[2:-1]:
                constr = constr + x

                print "tagged" + "\t" + random.choice(source_str) + constr
                count_1 = count_1 + 1
                constr_bak = constr
                
                flag_write = 1
                
        if flag == 0 and len(tmp[2]) != 0 and flag_write == 0:
            constr = ""
            for x in tmp[2:-1]:
                constr = constr + x
                
                print "unlabeled" + "\t" + random.choice(source_str) + constr
                count_0 = count_0 + 1

    except:
        pass

    counter_all = counter_all + 1
    line = f.readline() 

f = open('count.txt', 'w') 
f.write("count_0:" + str(count_0))
f.write("count_1:" + str(count_1)) 
f.close() # ファイルを閉じる
    
