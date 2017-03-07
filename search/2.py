import mmh3
import sys
MIN_HASH_VALUE = 2 ** 128

import socket, struct
from binascii import hexlify

src = 0
dst = 0

MIN_HASH_VALUE = 2 ** 128

def min_hash(words, seed):
    min_hash_word = None
    min_hash_value = MIN_HASH_VALUE

    for word in words:
        hash_ = mmh3.hash128(word, seed)
        if hash_ < min_hash_value:
            min_hash_word = word
            min_hash_value = hash_

    return min_hash_word


def calc_score(s1, s2, k):

    num_match = 0

    for seed in xrange(k):
        if min_hash(s1, seed) == min_hash(s2, seed):
            num_match += 1

    return float(num_match) / k

if __name__ == '__main__':

    argvs = sys.argv  
    argc = len(argvs) 

    f = open(argvs[1])
    
    line = f.readline() 

    alts = []
    ips = []
    lines = []
    
    while line:
        lines.append(line)
        tmp = line.split(",")

        counter = 0
        for i in tmp:
            #print i + ":" + str(counter)
            
            if counter == 32:
                alts.append(tmp[32])
            counter = counter + 1

        line = f.readline() 

    alts_uniq = list(set(alts)) 
        
    print alts_uniq
        
    f.close()

######

    f2 = open(argvs[1])
    
    line = f2.readline() 

    codedsessions = []
    
    while line:
        tmp = line.split(",")
        
        counter = 0
        for i in tmp:
            #print i + ":" + str(counter)

            if counter == 32:
                alts.append(tmp[32])
                #print tmp[32]

                counter2 = 0
                for a in alts_uniq:
                    if a == tmp[32]:

                        try:
                            #ip = tmp[7]
                            dst = struct.unpack('I', socket.inet_aton(tmp[7]))[0]
            
                            #ip = tmp[8]
                            src = struct.unpack('I', socket.inet_aton(tmp[8]))[0]

                        except:
                            pass
                            
                        codedsession = str(dst) + ":" + str(src) + ":" + str(counter2)
                        codedsessions.append(codedsession)
                        #print codedsession
                        
                    counter2 = counter2 + 1
                        
            counter = counter + 1
        
        line = f2.readline() 
    f2.close()

#########
        
    f3 = open(argvs[1])
    
    line = f3.readline() 

    s4 = codedsessions[0]
    print "COMPARED SESSION:" + s4 + ":" + lines[0]

    counter3 = 0
    while line:    
        k = 2 ** 10

        print "SIMILARITY:" + str(calc_score(line, s4, k))
        print lines[counter3]
        
        counter3 = counter3 + 1
        line = f3.readline() 
        
    f3.close()
