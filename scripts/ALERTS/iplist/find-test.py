import sys
import re

import pymongo
# mongodb へのアクセスを確立
client = pymongo.MongoClient('localhost', 27017)

from datetime import datetime as dt

# データベースを作成 
db = client.damballa
# コレクションを作成 
co = db.iplist

print("_time, ipaddress")

# 全部とってくる
for data in co.find():
    print(data["_time"] + "," + data["_id"])
