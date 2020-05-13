import xml.etree.ElementTree as ET 

import sys
args = sys.argv

tree = ET.parse(args[1]) 

root = tree.getroot()

t = args[1].split(".")
#print t[0]

ulist = []
for name in root.iter('title'):
    tmp = name.text.split("source")
    tmp2 = tmp[1].split(" ")
    tmpstr = t[0] + "," + tmp2[0].strip("=") + "," + tmp2[1]
    ulist.append(tmpstr)

uset = set(ulist)
# print uset
for i in uset:
    print i
