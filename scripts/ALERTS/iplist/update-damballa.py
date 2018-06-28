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
db = client.damballa
# コレクションを作成 
co = db.iplist

# データベースを作成 
db_all = client.PAFPDB
# コレクションを作成 
co_all = db_all.iplist

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
    #reader2 = geoip2.database.Reader('/usr/share/GeoIP/GeoLite2-ASN.mmdb')

    try:
        ip_addr = ipaddr
        record = reader.city(ip_addr)
        country_code = record.country.iso_code

        #print(ip_addr)
        with geoip2.database.Reader('/usr/share/GeoIP/GeoLite2-ASN.mmdb') as reader2:
            response = reader2.asn(ipaddr)
            asn = response.autonomous_system_number

        co.update({"_id": ipaddr},{'$setOnInsert': {"_id": ipaddr, "_time": datestr, "date": tmp[2].strip(), "country": country_code, "ASN": asn}}, upsert=True)

        co_all.update({"_id": ipaddr},{'$setOnInsert': {"_id": ipaddr, "_time": datestr, "date": tmp[2].strip(), "country": country_code, "ASN": asn}}, upsert=True)

    except:
        pass

    counter = counter + 1
    line = f.readline() 
f.close()

# 全部とってくる
for data in co.find():
    print(data)
