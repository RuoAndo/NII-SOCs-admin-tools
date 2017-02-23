import pprint
import sys, os
import sys 

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

sys.path.insert(0, os.path.abspath('../..'))
from lsh import LSHCache


if __name__ == '__main__':
    cache = LSHCache()

    line = f.readline() 

    docs = []
    
    while line:

        line.rstrip()
        docs.append(line)
        line = f.readline() 
        
    dups = {}
    for i, doc in enumerate(docs):
        dups[i] = cache.insert(doc.split(), i)

    for i, duplist in dups.items():
        if duplist:
            print 'orig [%d]: %s' % (i, docs[i])
            for dup in duplist:
                print'\tdup : [%d] %s' % (dup, docs[dup])
        else:
            print 'no dups found for doc [%d] : %s' % (i, docs[i])
