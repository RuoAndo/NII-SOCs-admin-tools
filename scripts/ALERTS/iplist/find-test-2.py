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

searchdate = str(argvs[1])

# 全部とってくる
#for data in co.find({"date":searchdate}).sort({"date":-1}):
for data in co.find({"date":searchdate}):
    print(data["_id"])
