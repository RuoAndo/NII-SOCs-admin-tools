# -*- coding:utf-8 -*-

import psycopg2

conn = psycopg2.connect(
    host = "192.168.1.1",
    port = 5432,
    database="xen460",
    user="postgres",
    password="")

cur = conn.cursor()

sql = "SELECT relname, n_tup_upd, n_tup_hot_upd, round(n_tup_hot_upd*100/n_tup_upd, 2) AS hot_upd_ratio FROM pg_stat_user_tables WHERE n_tup_upd > 0 ORDER BY hot_upd_ratio;"
cur.execute(sql)

ans =cur.fetchall()
print ans
        
#conn.commit()
cur.close()
conn.close()


