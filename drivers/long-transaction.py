# -*- coding:utf-8 -*-

import psycopg2

conn = psycopg2.connect(
    host = "192.168.1.1",
    port = 5432,
    database="xen460",
    user="postgres",
    password="")

cur = conn.cursor()
sql = "SELECT pid, waiting, (current_timestamp - xact_start)::interval(3) AS duration, query FROM pg_stat_activity WHERE pid <> pg_backend_pid();"
cur.execute(sql)

ans =cur.fetchall()
print ans


#sql = "SELECT procpid, waiting, (current_timestamp - xact_start)::interval(3) AS duration, current_query FROM pg_stat_activity WHERE procpid <> pg_backend_pid();"
#cur.execute(sql)

#ans =cur.fetchall()
#print ans

#conn.commit()
cur.close()
conn.close()


