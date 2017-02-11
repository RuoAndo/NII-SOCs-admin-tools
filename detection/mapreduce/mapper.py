#!/usr/bin/python

import sys
import re

for line in sys.stdin:
    line = re.sub( r'^W+|\W*$', '', line)
    words = re.split(r'\W+', line)

    for word in words:
        print ( word.lower() + "\t1")
