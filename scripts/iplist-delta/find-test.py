#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import re
import geoip2.database

import pymongo
# mongodb へのアクセスを確立
client = pymongo.MongoClient('localhost', 27017)

from datetime import datetime as dt

# データベースを作成 
db = client.session
# コレクションを作成 
co = db.iplist

argvs = sys.argv
argc = len(argvs)

# 全部とってくる
#{ "_id" : "133.5.12.1", "country" : "JP", "_time" : "2018/04/21 00:00:00", "delta" : "0", "date" : "20180421", "freq" : "388916", "ASN" : 2508 }

for data in co.find({"date":argvs[1]}):
    try:
        print(data["_time"]+","+data["_id"]+","+data["country"]+","+data["delta"]+","+str(data["date"])+","+str(data["freq"])+","+str(data["ASN"]))
    except:
        pass

#print co.find({"date":argvs[1]}).count()    
