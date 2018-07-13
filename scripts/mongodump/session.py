#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import re
import geoip2.database

import pymongo
# mongodb へのアクセスを確立
client = pymongo.MongoClient('192.168.72.6', 27017)

from datetime import datetime as dt

argvs = sys.argv
argc = len(argvs)

# データベースを作成 
db = client.session
# コレクションを作成 
co = db.iplist

#{u'country': u'JP', u'_time': u'2018/04/21 00:00:00', u'delta': u'1', u'date': u'20180421', u'freq': u'6', u'_id': u'219.119.115.108', u'ASN': 2497}^C
for data in co.find():
    try:
        print data["_time"] + "," + data["_id"] + "," + data["delta"] + "," + data["date"] + "," + data["freq"] + "," + data["country"]
    except:
        pass
