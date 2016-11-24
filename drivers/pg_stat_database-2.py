import time
import psycopg2
import os

connection3 = psycopg2.connect(host="127.0.0.1", port=5432, database="sample", user="postgres", password="")
cursor5 = connection3.cursor()
cursor5.execute("SELECT * FROM pg_stat_database WHERE datname = 'sample';")
stats = cursor5.fetchall()

#  datid |  datname   | numbackends | xact_commit | xact_rollback | blks_read  |  blks_hit   | tup_returned | tup_fetched | tup_inserted | tup_updated | tup_deleted | conflicts | temp_files |  temp_bytes  | deadlocks | blk_read_time | blk_write_time |          stats_reset          |     size

result = {}
for stat in stats:
    database = stat[1]
    result[database] = stat

#print stats

print "datid |  datname   | numbackends | xact_commit | xact_rollback | blks_read  |  blks_hit   | tup_returned | tup_fetched | tup_inserted | tup_updated | tup_deleted | conflicts | temp_files |  temp_bytes  | deadlocks | blk_read_time | blk_write_time | stats_reset | size"

#print stats

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

#print "datid |  datname   | numbackends | xact_commit | xact_rollback | blks_read  |  blks_hit   | tup_returned | tup_fetched | tup_inserted | tup_updated | tup_deleted | conflicts | temp_files |  temp_bytes  | deadlocks | blk_read_time | blk_write_time | stats_reset | size"

connection3.close()
cursor5.close()

num = 0
while num < 2000:
        
    connection4 = psycopg2.connect(host="127.0.0.1", port=5432, database="sample", user="postgres", password="")
    cursor6 = connection4.cursor()
    cursor6.execute("SELECT * FROM pg_stat_database WHERE datname = 'sample';")
    stats = cursor6.fetchall()

    str = ""
    for row in stats:
        str = str + unicode(row[0])
        str = str + "," + unicode(row[1])
        str = str + "," + unicode(row[2])
        str = str + "," + unicode(row[3])
        str = str + "," + unicode(row[4])
        str = str + "," + unicode(row[5])
    
        str = str + "," + unicode(row[6])
        str = str + "," + unicode(row[7])
        str = str + "," + unicode(row[8])
        str = str + "," + unicode(row[9])
        str = str + "," + unicode(row[10])
        str = str + "," + unicode(row[11])

        str = str + "," + unicode(row[12])
        str = str + "," + unicode(row[13])
        str = str + "," + unicode(row[14])
        str = str + "," + unicode(row[15])
        str = str + "," + unicode(row[16])
        str = str + "," + unicode(row[17])
        str = str + "," + unicode(row[18])

    print str

    time.sleep(5)
    num = num + 1
