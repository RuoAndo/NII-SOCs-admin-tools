import slumber
import sys 
argvs = sys.argv 

api = slumber.API("https://cymon.io/api/nexus/v1/")
r = api.ip(argvs[1]).events().get()
print argvs[1] + ";" + str(r)
