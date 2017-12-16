#!/usr/bin/env python

import commands
import sys
argvs = sys.argv  

comstr = "./getDataCsv.sh SESSION " + "\"" + argvs[1] + " 00:00" + "\"" + " \"" + argvs[2] + " 00:00\"" 
print comstr
check = commands.getoutput(comstr)
print check
