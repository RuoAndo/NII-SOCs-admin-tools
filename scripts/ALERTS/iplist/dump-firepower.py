#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import re

import pymongo
# mongodb へのアクセスを確立
client = pymongo.MongoClient('localhost', 27017)

from datetime import datetime as dt

# データベースを作成 
db = client.firepower
# コレクションを作成 
co = db.iplist

argvs = sys.argv
argc = len(argvs)

print("_time, ipaddress, country, ASN")

# 全部とってくる
for data in co.find():
    print(data["_time"] + "," + data["_id"] + "," + str(data["country"]) + "," + str(data["ASN"]))
