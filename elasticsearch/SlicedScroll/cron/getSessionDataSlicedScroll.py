#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
このスクリプトではエイリアスから全ログをSlicedScrollを用いて非同期で検索する。
"""
import sys
import logging
import logging.config

argvs = sys.argv
argc = len(argvs)

if (argc != 6):
    print('Parameter Error')
    print('Usage: ./getSessionDataSlicedScroll.py search_X.json user passwd address(IP:port) indexname')
    quit()

search_file = argvs[1]
user = argvs[2]
passwd = argvs[3]
address = argvs[4]
indexname = argvs[5]

from elasticsearch import Elasticsearch
import datetime
import json
 
# jsonファイルを読み込む
f = open(search_file)
data = json.load(f)
f.close()

class Search_Sessionlog_Sliced_Scroll(object):
    def main(self):

        # ログ出力設定
        logging.config.fileConfig('logging.conf')
        logger = logging.getLogger('Search_Sessionlog_Sliced_Scroll')

        logger.info('%s のデータ出力を開始しました',search_file)

        self.es = Elasticsearch(
            [address],
            http_auth=(user, passwd),
            timeout=180)

        res = self.es.search(
            index=indexname,
            size="10000",
            scroll="30s",
            body=data
            )

        # get scroll id
        scroll_id = res["_scroll_id"]

        # convert json
        response = json.dumps(res, indent=2, separators=(',', ': '))

        # output
        print response

        num=1
        # 全ログを検索する
        while 0 < len(res["hits"]["hits"]):
            res = self.es.scroll(scroll_id=scroll_id, scroll="30s")
            response_scroll = json.dumps(res, indent=2, separators=(',', ': '))

            # output
            print response_scroll

             # 性能優先のためログ出力を抑制 以下コメントアウト
#            num+=1
#            mod = num % 10
#            if mod == 0:
#                mult = num * 10000
#                logger.info('%s のデータ出力済件数 : %s 件',search_file, '{:,}'.format(mult))

        logger.info('%s のデータ出力が完了しました',search_file)

if __name__ == '__main__':
    search_sessionlog_all = Search_Sessionlog_Sliced_Scroll()
    search_sessionlog_all.main()


