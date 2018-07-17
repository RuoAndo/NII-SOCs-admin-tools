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
db = client.session
# コレクションを作成 
co = db.iplist

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 

#print("t")

#DELTA,329319,130.54.130.240,1,16726
#delta-sorted-20180508

counter = 0
while line:

    tmp = argvs[1].split("-")
    tmp2 = line.split(",")    
   
    datestr=str(dt.strptime(tmp[2],'%Y%m%d')).replace("-","/")
    ipaddr=tmp2[2]

    reader = geoip2.database.Reader('/usr/local/share/GeoIP/GeoLite2-City.mmdb')

    try:
        ip_addr = ipaddr
        record = reader.city(ip_addr)
        country_code = record.country.iso_code

        #print(ip_addr)
        with geoip2.database.Reader('/usr/share/GeoIP/GeoLite2-ASN.mmdb') as reader2:
            response = reader2.asn(ipaddr)
            asn = response.autonomous_system_number

            #DELTA,329319,130.54.130.240,1,16726
        co.update({"_id": ipaddr},{'$setOnInsert': {"_id": ipaddr, "_time": datestr, "date": tmp[2].strip(), "country": country_code, "ASN": asn, "delta": tmp2[3], "freq": tmp2[4].strip()}}, upsert=True)

    except:
        pass

    counter = counter + 1
    line = f.readline() 
f.close()

# 全部とってくる
counter = 0
for data in co.find():
    if counter % 50000 == 0:
        print(data)
    counter = counter + 1
