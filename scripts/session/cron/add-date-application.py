#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import re
from datetime import datetime as dt

argvs = sys.argv
argc = len(argvs)

datestr=str(dt.strptime(argvs[2],'%Y%m%d')).replace("-","/")

f = open(argvs[1])
line = f.readline() 
while line:
    #tmp = line.split(",")
    print(datestr + "," + line.strip())
    line = f.readline() 
f.close()

