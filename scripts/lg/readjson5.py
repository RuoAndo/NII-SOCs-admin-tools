import sys
import re
import json

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1], 'r')
jsonData = json.load(f)

#delta/delta-sorted-20180522_ip_detailed_data.txt

dtmp = argvs[1].split("/")
ntmp = dtmp[1].split("-")
ntmp2 = ntmp[2].split("_")
#print dtmp

#print jsonData
#print jsonData['60.39.9.150']['system tags']

iplist = []

counter = 0
for i in jsonData:
    ip = i
    #print jsonData[ip]['system tags']
    if len(str(jsonData[ip]['system tags'])) > 10:
        if str(jsonData[ip]['system tags']).find(argvs[2]) > -1:
        #if argvs[2].lower() in str(jsonData[ip]['system tags']).lower():
            print str(ntmp2[0]) + "," + str(ip) + "," + str(jsonData[ip]['system tags'])
            #iplist.append(str(ip))

            counter = counter + 1
        #print str(ip) 
        #print str(jsonData[ip]['system tags'])
#print "(" + str(counter) + ")"

#iplist_uniq = list(set(iplist))
#print iplist_uniq
