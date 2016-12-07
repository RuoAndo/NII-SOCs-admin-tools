
#!/usr/bin/env python

import sys

argvs = sys.argv


means = []
cluster = []

for line in open(argvs[1], 'r'):
    tmp = line.split(" ")
    means.append(tmp[1].strip())
    cluster.append(tmp[0])
    
for i in cluster:
    print i
    print means[int(i)]

    
    
