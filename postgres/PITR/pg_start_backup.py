import sys 
import psycopg2

argvs = sys.argv  
argc = len(argvs) 

dbname = argvs[1]

conn = psycopg2.connect(
    host = "127.0.0.1",
    port = 5432,
    database=dbname,
    user="postgres",
    password="")

cur = conn.cursor()

sql = "select pg_start_backup('label')"
cur.execute(sql)

cur.close()
conn.close()

