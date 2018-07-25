#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import re
import geoip2.database

import pymongo

import ipaddress

# mongodb へのアクセスを確立
client = pymongo.MongoClient('localhost', 27017)

from datetime import datetime as dt

# データベースを作成 
db = client.delta
# コレクションを作成 
co = db.iplist

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 

counter = 0
while line:

    tmp = line.split(",")    
    ipaddr=str(tmp[1])
    print ipaddr

    try:
        if ipaddress.ip_address(unicode(ipaddr)) == True:
            reader = geoip2.database.Reader('/usr/share/GeoIP/GeoLite2-City.mmdb')

            record = reader.city(ipaddr)
            country_code = record.country.iso_code
    
            with geoip2.database.Reader('/usr/share/GeoIP/GeoLite2-ASN.mmdb') as reader2:
                response = reader2.asn(ipaddr)
                asn = response.autonomous_system_number

            co.update({"_id": ipaddr},{'$setOnInsert': {"_id": ipaddr, "date": tmp[0], "country": country_code, "ASN": asn, "tag": tmp[2].strip()}}, upsert=True)

    except:
        pass


    line = f.readline() 
f.close()

# 全部とってくる
counter = 0
for data in co.find():
    if counter % 50000 == 0:
        print(data)
    counter = counter + 1
