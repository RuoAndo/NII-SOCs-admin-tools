# python 1.py tools/libxl/libxl.c libxl 372

import sys 

if __name__ == '__main__':

    argvs = sys.argv  
    argc = len(argvs) 

    f = open(argvs[1])
    
    line = f.readline() 

    reasons = []
    
    while line:
        tmp = line.split(",")
        #print tmp[36]
        try:
            reasons.append(tmp[36])
        except:
            pass
            
        line = f.readline() 

    reasons_uniq = list(set(reasons)) 
    print reasons_uniq
    
    f.close()
