#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import re
import geoip2.database

import pymongo
# mongodb へのアクセスを確立
client = pymongo.MongoClient('localhost', 27017)

from datetime import datetime as dt

argvs = sys.argv
argc = len(argvs)

# データベースを作成 
db = client.PAFPDB
# コレクションを作成 
co = db.iplist

# 全部とってくる
#{u'date': u'20180225', u'_time': u'2018/02/25 00:00:00', u'_id': u'133.54.102.107', u'ASN': 2907, u'country': u'JP'}

#print "date, _time, ipaddr, ASN, country"
#for data in co.find({"date":searchdate}).sort({"date":-1}):
for data in co.find():
    try:
        print str(data["_time"]) + "," + data["date"] + "," + data["_id"] + "," + str(data["ASN"]) + "," + data["country"]
    except:
        pass
