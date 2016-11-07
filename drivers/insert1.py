import sys 
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

sql = "create TABLE test(id INT, name varchar(1024));"
cur.execute(sql)

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

counter = 0
line = f.readline() 
while line:

    tmp = line.split(":")
    print tmp

    sql = "INSERT INTO test (id, name) VALUES (" + str(counter) + ", '" + tmp[0] + "');"
    print sql
    cur.execute(sql)

    counter=counter + 1
    line = f.readline() 

cur.execute("SELECT * FROM pg_stat_database WHERE datname = 'sample';")
stats = cur.fetchall()

#  datid |  datname   | numbackends | xact_commit | xact_rollback | blks_read  |  blks_hit   | tup_returned | tup_fetched | tup_inserted | tup_updated | tup_deleted | conflicts | temp_files |  temp_bytes  | deadlocks | blk_read_time | blk_write_time |          stats_reset          |     size

result = {}
for stat in stats:
    database = stat[1]
    result[database] = stat

print stats
    
for database in result:
    for i in range(2,len(cur.description)):
        metric = cur.description[i].name
        value = result[database][i]
        try:
            if metric in ("stats_reset"):
                continue
            print ("postgresql.%s %i %s database=%s"
                   % (metric, ts, value, database))
        except:
            #utils.err("got here")
            continue

conn.commit()
cur.close()
conn.close()

