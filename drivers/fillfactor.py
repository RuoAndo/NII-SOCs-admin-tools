# -*- coding:utf-8 -*-

import psycopg2

conn = psycopg2.connect(
    host = "192.168.1.1",
    port = 5432,
    database="sample",
    user="postgres",
    password="")

cur = conn.cursor()

sql = "SELECT nspname as schema, relname, relkind, reloptions FROM pg_class C LEFT JOIN pg_namespace N ON relnamespace = N.oid WHERE relkind IN ('i', 'r') AND nspname = 'public';"
cur.execute(sql)

ans =cur.fetchall()
print ans
        
#conn.commit()
cur.close()
conn.close()


