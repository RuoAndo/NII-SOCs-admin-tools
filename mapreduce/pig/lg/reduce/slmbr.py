import slumber
import sys 
import json

argvs = sys.argv 

api = slumber.API("https://cymon.io/api/nexus/v1/")
r = api.ip(argvs[1]).events().get()

#data = json.dumps(r)
data = json.loads(json.dumps(r))

for i in data['results']:
    print argvs[1] + ":" + i['title']




