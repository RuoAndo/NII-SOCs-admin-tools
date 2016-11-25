import sys
import datetime
import time
import psycopg2
import random
import string
from datetime import datetime

argvs = sys.argv  
argc = len(argvs)

conn = psycopg2.connect(
    host = "127.0.0.1",
    port = 5432,
    database="nos",
    user="postgres",
    password="")

cur = conn.cursor()

#sql = "drop TABLE test;"
#cur.execute(sql)

#sql = "create TABLE test(id INT, name varchar(1024));"
#cur.execute(sql)

#sql = "INSERT INTO test (id, name) VALUES (" + str(counter) + ", '" + tmp[0] + "');"

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 
str1 = ""
str2 = ""

sql = ""

while line:
    tmp = line.split(",")
    
    str1 = str1 + tmp[0] + ","
    
    #print tmp[1].rstrip()

    if tmp[1].rstrip() == "date":
        str2 = str2 + "'" + str(datetime.today()) + "'" + ","

    elif tmp[1].rstrip() == "time":
        dt = datetime.now()
        str2 = str2 + "'" + str(dt) + "'" + ","
        
    elif tmp[1].rstrip() == "timestamp":
        tm = time.time()
        str2 = str2 + "'" + str(datetime.fromtimestamp(tm)) + "'" + ","

    elif tmp[1].rstrip() == "integer":
        it = random.randint(1,100)
        str2 = str2 + str(random.randint(1,100)) + ","

    elif tmp[1].rstrip() == "bigint":
        str2 = str2 + str(random.randint(1,100)) + ","

    elif tmp[1].rstrip().find("varchar"):
        n = 2
        random_str = ''.join([random.choice(string.ascii_letters + string.digits) for i in range(n)])
        str2 = str2 + "'" + random_str + "'" + ","

    elif tmp[1].rstrip().find("text"):
        n = 3
        random_str = ''.join([random.choice(string.ascii_letters + string.digits) for i in range(n)])
        str2 = str2 + "'" + random_str + "'" + ","

    line = f.readline() 

sql1 = "(" + str1.rstrip(",") + ")"
#print sql1
#print "####"

sql2 = "(" + str2.rstrip(",") + ")"
#print sql2
#print "####"

sql3 = "INSERT INTO " + argvs[1] + " " + sql1 + " VALUES "+ sql2 + ";"
print sql3

cur.execute(sql3)
conn.commit()

cur.close()
conn.close()
