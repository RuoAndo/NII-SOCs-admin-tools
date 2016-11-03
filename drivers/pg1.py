# -*- coding:utf-8 -*-

import psycopg2

conn = psycopg2.connect(
    host = "192.168.1.1",
    port = 5432,
    database="sample",
    user="postgres",
    password="")

cur = conn.cursor()

sql = "drop TABLE test;"
cur.execute(sql)

sql = "create TABLE test(id INT, name varchar(40));"
cur.execute(sql)

sql = "INSERT INTO test (id, name) VALUES (3, 'hanako');"
cur.execute(sql)

sql = "select * from test"
cur.execute(sql)

ans =cur.fetchall()
print ans

#dict_result = []
#for row in ans:
#    dict_result.append(dict(row))

#print dict_result
        
conn.commit()
cur.close()
conn.close()


