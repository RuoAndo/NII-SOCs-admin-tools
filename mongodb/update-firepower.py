import sys
import re
import geoip2.database

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

f = open(argvs[1])
line = f.readline() 

#print("t")

counter = 0
while line:
    tmp = argvs[1].split("-")
    
    datestr=str(dt.strptime(tmp[2],'%Y%m%d')).replace("-","/")
    ipaddr=line.strip()

    reader = geoip2.database.Reader('/usr/local/share/GeoIP/GeoLite2-City.mmdb')

    try:
        ip_addr = ipaddr
        record = reader.city(ip_addr)
        country_code = record.country.iso_code

        co.update({"_id": ipaddr},{'$setOnInsert': {"_id": ipaddr, "_time": datestr, "date": tmp[2].strip(), "country": country_code}}, upsert=True)

    except:
        pass

    counter = counter + 1
    line = f.readline() 
f.close()

# 全部とってくる
for data in co.find():
    print(data)
