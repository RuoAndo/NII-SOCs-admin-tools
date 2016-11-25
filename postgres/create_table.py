import sys 
import psycopg2

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

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 
str = ""
sql = ""

while line:
    tmp = line.split(",")
    str = tmp[0] + " " + tmp[1].strip()
    sql = sql + "," + str

    line = f.readline() 

sql = sql.lstrip(",")
print sql

sql2 = "create TABLE " + argvs[1] + "(" + sql + ");"
print sql2
cur.execute(sql2)
conn.commit()
