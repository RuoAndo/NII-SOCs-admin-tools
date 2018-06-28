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

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 

#print("t")

counter = 0
while line:
    tmp = argvs[1].split("-")
    
    datestr=str(dt.strptime(tmp[2],'%Y%m%d')).replace("-","/")
    ipaddr=line.strip()

    co.update({"_id": ipaddr},{'$setOnInsert': {"_id": ipaddr, "_time": datestr, "date": tmp[2].strip()}}, upsert=True)

    counter = counter + 1
    line = f.readline() 
f.close()

# 全部とってくる
for data in co.find():
    print(data)
