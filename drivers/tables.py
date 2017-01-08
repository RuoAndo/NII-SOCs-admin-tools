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

cursor = conn.cursor()
cursor.execute("select relname from pg_class where relkind='r' and relname !~ '^(pg_|sql_)';")
print cursor.fetchall()

