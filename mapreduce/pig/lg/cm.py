# -*- coding: utf-8 -*-

import sys
import json

argvs = sys.argv
argc = len(argvs)
 
f = open(argvs[1], 'r')
json_dict = json.load(f)

#print json_dict

#for x in json_dict:
#    print x

if json_dict['results'] != "":
    print json_dict['results']
