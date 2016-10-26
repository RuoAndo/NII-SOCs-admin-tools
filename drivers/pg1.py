# -*- coding:utf-8 -*-

import psycopg2

conn = psycopg2.connect(
    host = "192.168.1.1",
    port = 5432,
    database="sample",
    user="postgres",
    password="")

cur = conn.cursor()

cur.execute("INSERT INTO test (id, name) VALUES (%s, %s)", (1, "test"))

conn.commit()
cur.close()
conn.close()


