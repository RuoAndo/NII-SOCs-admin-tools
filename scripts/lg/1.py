import sys
import re
#import ipaddress

argvs = sys.argv
argc = len(argvs)

#print argvs[1]
#tmp = re.split([((?:(?:25[0-5]|2[0-4]\\d|[01]?\\d?\\d)\\.){3}(?:25[0-5]|2[0-4]\\d|[01]?\\d?\\d))], argv[1]) 

tmp = argvs[1].split("__")

counter = 0

for x in tmp:

    print x
    
    if counter % 2 == 0:
        print "###\n"

    counter = counter + 1
