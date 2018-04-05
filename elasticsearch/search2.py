import sys

argvs = sys.argv
argc = len(argvs)

if (argc != 7):  
    print('Usage: python search.py auth(user:passwd) address(IP:port) port indexname key value limit')
    quit()       

authinfo = argvs[1]
address = argvs[2]
indexname = argvs[3]
key = argvs[4]
value = argvs[5]
slimit = argvs[6]

from elasticsearch import Elasticsearch
from time import time

str = "http://" + authinfo + "@" + address

print(str)
es = Elasticsearch(str)

response = es.search(index=indexname, body={"query": {"match": {key: value}}})
#print(response)

counter = 0
for x in response['hits']['hits']:                                                                                
    if counter < int(slimit):    
        # print(x)
        print(x['_source'])

    else:
        break

    print("###")

    counter = counter + 1
