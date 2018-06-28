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
db = client.firepower
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

    datestr=str(dt.strptime(tmp[1],'%Y%m%d')).replace("-","/")
    ip_addr=line.strip()

    try:

        reader = geoip2.database.Reader('/usr/share/GeoIP/GeoLite2-Country.mmdb')
        response = reader.country(ip_addr)
        country_code=(response.country.iso_code)
        
        with geoip2.database.Reader('/usr/share/GeoIP/GeoLite2-ASN.mmdb') as reader2:
            response = reader2.asn(ip_addr)
            asn = response.autonomous_system_number
        
        date6digit=tmp[1].strip()

        co.update({"_id": ip_addr},{'$setOnInsert': {"_id": ip_addr, "_time": datestr, "date": date6digit, "country": country_code, "ASN": asn}}, upsert=True)

        co_all.update({"_id": ip_addr},{'$setOnInsert': {"_id": ip_addr, "_time": datestr, "date": date6digit, "country": country_code, "ASN": asn}}, upsert=True)

    except:
        asn="NA"
        country_code="NA"

        co.update({"_id": ip_addr},{'$setOnInsert': {"_id": ip_addr, "_time": datestr, "date": date6digit, "country": country_code, "ASN": asn}}, upsert=True)

        co_all.update({"_id": ip_addr},{'$setOnInsert': {"_id": ip_addr, "_time": datestr, "date": date6digit, "country": country_code, "ASN": asn}}, upsert=True)

    counter = counter + 1
    line = f.readline() 
f.close()

#print(tmp[1].strip())

searchdate = tmp[1].strip()

# 全部とってくる
#for data in co.find({"date":searchdate}).sort({"date":-1}):
for data in co.find({"date":searchdate}):
    print(data)
