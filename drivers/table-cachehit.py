# -*- coding:utf-8 -*-
import sys
import psycopg2

argvs = sys.argv  
argc = len(argvs) 

dbname = argvs[1]

conn = psycopg2.connect(
    host = "192.168.1.1",
    port = 5432,
    database=dbname,
    user="postgres",
    password="")

cur = conn.cursor()

sql = "SELECT datname, round(blks_hit*100/(blks_hit+blks_read), 2) AS cache_hit_ratio FROM pg_stat_database WHERE blks_read > 0;"

cur.execute(sql)
conn.commit

ans =cur.fetchall()

for stat in ans:
    print stat
    
#conn.commit()
cur.close()
conn.close()


