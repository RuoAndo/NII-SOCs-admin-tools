#!/usr/bin/env python

import sys
sys.path.append('.')

for line in sys.stdin:
        fields = line.strip().split()
        print '%s\t%s' % (fields[0],1)

