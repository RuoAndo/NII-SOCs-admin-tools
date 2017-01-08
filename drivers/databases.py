import time
import psycopg2
import os

import sys
import re
import commands

from pymongo import Connection
connect = Connection('127.0.0.1', 27017)

db = connect.pgstat
collect = db.pgstat

connection3 = psycopg2.connect(host="192.168.1.1", port=5432, database="sample", user="postgres", password="")
cursor5 = connection3.cursor()
cursor5.execute("SELECT * FROM pg_database;")
stats = cursor5.fetchall()

result = {}
for stat in stats:
    print stat[0]

    dbname = stat[0]

    try:
        conn = psycopg2.connect(
            host = "127.0.0.1",
            port = 5432,
            database=dbname,
            user="postgres",
            password="")

        cursor = conn.cursor()
        cursor.execute("select relname from pg_class where relkind='r' and relname !~ '^(pg_|sql_)';")
        print cursor.fetchall()

    except:
        pass
    
