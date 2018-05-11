import commands
import json
import subprocess

es_url="192.168.68.40:9200"
index="trafficlog_2018.01.18"

SCROLL_MAX = 6

num = 0
while num < SCROLL_MAX:

  constr="curl -u elastic:GPt_zdL4 -s " + es_url + "/" +index + "/_search?scroll=2m -d @query.json \"slice\": {\"id\": + " + str(num) + ", \"max\": SCROLL_MAX}"

  try:
      check = commands.getoutput(constr)
      test = json.loads(check)  
      sid = test['_scroll_id']

      constr2="timeout 120 ./sub.sh " + sid + " > tmptest" + str(num) + " &"
      #constr2="timeout 10 ./sub.sh " + sid + " > tmptest" + str(num)
      print constr2
      proc = subprocess.call( constr2 , shell=True)

  except:
      print "error at:" + str(num)
      pass

  num = num + 1

