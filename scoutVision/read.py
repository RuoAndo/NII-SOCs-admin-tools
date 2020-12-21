# -*- coding: utf-8 -*-

fileobj = open("header", "r")
line = fileobj.readline()
#print line

tmp = line.split(",")
#print tmp

line = fileobj.readline()
#print line

tmp2 = line.split(",")
#print tmp2

counter = 0
for i in tmp:
    
    print(str(i).strip() + "," + str(tmp2[counter]))
    counter = counter + 1  

