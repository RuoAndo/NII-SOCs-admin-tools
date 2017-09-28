import sys 
import redis

argvs = sys.argv  
argc = len(argvs) 

r = redis.Redis(host=argvs[1], port=6379, db=0)

print r.lrange(argvs[2],0,-1)  


