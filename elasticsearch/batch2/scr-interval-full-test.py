#!/usr/bin/python
# -*- coding: utf-8 -*-

from elasticsearch import Elasticsearch
import datetime
import json

from datetime import datetime
from dateutil import tz
paristimezone = tz.gettz('Asia/Tokyo')

import sys

argvs = sys.argv                                                                                               
argc = len(argvs) 

class Search_Sessionlog_all(object):
    def main(self):

        tmp = argvs[2].split(" ")
        tmp2 = tmp[0].replace("/",".")

        indexname="trafficlog_" + tmp2
        #print indexname

        self.es = Elasticsearch(
            ['192.168.68.40:9200'],
            http_auth=('elastic', 'GPt_zdL4'),
            timeout=180)

        res = self.es.search(
            index=indexname,
            size="10000",
            scroll="1m",
            body={
                "query" : {
                    "range" : {
                         # "generated_time" : { "gte" : u'2018/01/18 00:00:00', "lte" : u'2018/01/18 02:00:00' }
                         "generated_time" : { "gte" : argvs[1], "lte" : argvs[2] }
                    }
                }
            })
 
        scroll_id = res["_scroll_id"]

        #print('total: {}'.format(res["hits"]["total"]))
        #print('took: {}'.format(res["took"]))

        took_all = 0

        print("generated_time" + "," + "srcip" + "," + "destip" + "," + "source_port" + "," + "destination_port" + "," + "bytes" + "," + "bsent" + "," + "brecv" + "," + "application" + "," + "session_end_reason" + "," + "subtype" + "," + "action_source" + "," + "tunnel_type" + "," + "log_forwarding_profile" + "," + "protocol" + "," + "flags" + "," + "source_zone" + "," + "rule_name" + "," + "src_country_code" + "," + "action" + "," + "dest_country_code" + "," + "destination_zone")

        while 0 < len(res["hits"]["hits"]):
            
            res = self.es.scroll(scroll_id=scroll_id, scroll="1m")
            #print('took: {}'.format(res["took"]))

            for x in res['hits']['hits']:

                generated_time = str(x['_source']['generated_time']).rstrip() 

                destip = str(x['_source']['destination_ip']).rstrip() 
                srcip = str(x['_source']['source_ip']).rstrip() 

                source_port = str(x['_source']['source_port']).rstrip() 
                destination_port = str(x['_source']['destination_port']).rstrip() 

                bytes = str(x['_source']['bytes']).rstrip() 
                bsent = str(x['_source']['bytes_sent']).rstrip() 
                brecv = str(x['_source']['bytes_received']).rstrip()
 
                application = str(x['_source']['application']).rstrip()
                session_end_reason = str(x['_source']['session_end_reason']).rstrip() 
                subtype = str(x['_source']['subtype']).rstrip() 
                action_source = str(x['_source']['action_source']).rstrip() 
                tunnel_type = str(x['_source']['tunnel_type']).rstrip()
                log_forwarding_profile = str(x['_source']['log_forwarding_profile']).rstrip()
                protocol = str(x['_source']['protocol']).rstrip() 
                source_zone = str(x['_source']['source_zone']).rstrip() 
                rule_name = str(x['_source']['rule_name']).rstrip()
                src_country_code = str(x['_source']['src_country_code']).rstrip() 

                action = str(x['_source']['action']).rstrip() 
                dest_country_code = str(x['_source']['dest_country_code']).rstrip()
                destination_zone = str(x['_source']['destination_zone']).rstrip()
                flags = str(x['_source']['flags']).rstrip() 

                constr = generated_time + "," + srcip + "," + destip + "," + source_port + "," + destination_port + "," + bytes + "," + bsent + "," + brecv + "," + application + "," + session_end_reason + "," + subtype + "," + action_source + "," + tunnel_type + "," + log_forwarding_profile + "," + protocol + "," + flags + "," + source_zone + "," + rule_name + "," + src_country_code + "," + action + "," + dest_country_code + "," + destination_zone 

                print(constr)

            took_all = took_all + int(res["took"])

            #print took_all

            #if took_all > 2000000:
            #    break


if __name__ == '__main__':
    search_sessionlog_all = Search_Sessionlog_all()
    search_sessionlog_all.main()

