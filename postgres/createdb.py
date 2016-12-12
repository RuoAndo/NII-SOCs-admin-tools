#!/usr/bin/python
# -*- coding: utf-8 -*-

from psycopg2 import connect
import sys
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

con = None
con = connect(user='postgres', host = '127.0.0.1', password='')

dbname = "sample"

con.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
cur = con.cursor()
cur.execute('CREATE DATABASE ' + dbname)
cur.close()
con.close()
