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
db = client.PAFPDB
# コレクションを作成 
co = db.iplist

# 全部とってくる
#for data in co.find({"date":searchdate}).sort({"date":-1}):
for data in co.find({"date":"20180627"}):
    print(data["_id"])
