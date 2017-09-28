import sys 
import redis
from datetime import datetime

r = redis.Redis(host='127.0.0.1', port=6379, db=0)

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 

while line:
    if line.find(":") > -1:
        tmp = line.split(":")
        if len(tmp[1]) > 3: #length of []
            tmp2 = tmp[1].split(",")
            #print tmp2

            for i in tmp2:
                print tmp[0] + "," + i.replace("u'","").replace("'","").strip()
                rkey = tmp[0]
                rvalue = i.replace("u'","").replace("'","").strip()
                r.rpush(rkey,rvalue)  

                datestr = datetime.now().strftime("%Y/%m/%d %H:%M:%S")
                print datestr
                r.rpush(rkey,datestr)  
                
    line = f.readline()

