import redis
import sys 

argvs = sys.argv  
argc = len(argvs) 

r = redis.Redis(host='127.0.0.1', port=6379, db=0)
print r.get(argvs[1]) 
