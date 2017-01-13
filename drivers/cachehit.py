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

#sql = "SELECT relname, heap_blks_read, heap_blks_hit, CASE WHEN heap_blks_read = 0 THEN 0.00 ELSE round(100* heap_blks_read/(heap_blks_read + heap_blks_hit), 2) END AS hit_ratio FROM pg_statio_all_tables WHERE relname LIKE 'pgbench%';"

#sql = "SELECT relname, heap_blks_read, heap_blks_hit FROM pg_statio_all_tables WHERE relname LIKE 'pgbench%';"

sql = "SELECT relname, heap_blks_read, heap_blks_hit FROM pg_statio_all_tables;"

cur.execute(sql)
conn.commit

ans =cur.fetchall()
print ans
        
#conn.commit()
cur.close()
conn.close()


