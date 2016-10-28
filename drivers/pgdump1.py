
import time
import psycopg2
import os

connection3 = psycopg2.connect(host="192.168.1.1", port=5432, database="sample", user="postgres", password="")
cursor5 = connection3.cursor()
os.system('pg_dump -U postgres -s sample > test.txt')
current_time = time.strftime("%c")
current_time_tbl = '"' + current_time + '"'
cursor5.execute("alter table test rename to %s;" % (current_time_tbl))
#cursor5.execute("select * from test;")
connection3.commit()
