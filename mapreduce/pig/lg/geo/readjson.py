import sys
import re
import json

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1], 'r')
jsonData = json.load(f)

#print jsonData
#print jsonData['60.39.9.150']['system tags']

for i in jsonData:
    ip = i
    print str(ip) + ":" + str(jsonData[ip]['system tags'])

