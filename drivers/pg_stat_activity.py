import time
import psycopg2
import os

connection3 = psycopg2.connect(host="192.168.1.1", port=5432, database="sample", user="postgres", password="")
cursor5 = connection3.cursor()
cursor5.execute("SELECT * FROM pg_stat_activity WHERE datname = 'sample';")
stats = cursor5.fetchall()

#  datid |  datname   | numbackends | xact_commit | xact_rollback | blks_read  |  blks_hit   | tup_returned | tup_fetched | tup_inserted | tup_updated | tup_deleted | conflicts | temp_files |  temp_bytes  | deadlocks | blk_read_time | blk_write_time |          stats_reset          |     size

result = {}
for stat in stats:
    database = stat[1]
    result[database] = stat

print stats
    
for database in result:
    for i in range(2,len(cursor5.description)):
        metric = cursor5.description[i].name
        value = result[database][i]
        try:
            if metric in ("stats_reset"):
                continue
            print ("postgresql.%s %i %s database=%s"
                   % (metric, ts, value, database))
        except:
            #utils.err("got here")
            continue
