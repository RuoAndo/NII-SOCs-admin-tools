import sys 
import psycopg2


conn = psycopg2.connect(
    host = "192.168.1.1",
    port = 5432,
    database="sample",
    user="postgres",
    password="")

cur = conn.cursor()

sql = "select count(*) from test;"
cur.execute(sql)

stats = cur.fetchall()
print stats
