import sys
import re
import commands
import random
from operator import itemgetter

argvs = sys.argv
argc = len(argvs)

f = open(argvs[1])
line = f.readline() 

while line:
    tmp = line.split(",")

    if int(tmp[0]) == 0:

        f3 = open(argvs[1])
        line3 = f3.readline() 

        tlist = []
        while line3:
            tmp3 = line3.split(",")
            tlist.append(tmp3)
            line3 = f3.readline() 

        f3.close()
     
        #tmp4 =  tlist.sort(key=itemgetter(0))
        tmp4 = sorted(tlist)[-2]
        #print tmp4
        #print tmp4

        tmpstr4 = tmp4[2] + "," + tmp4[3] + "," + tmp4[4].strip()

        f2 = open('tmp-c', 'w')
        f2.write(tmpstr4)
        f2.close()

        check = commands.getoutput("./avg-fill2.sh tmp-c all2 > tmp-c2")
        check2 = commands.getoutput("cat tmp-c2")        
        check3 = check2.split("\n")

        check3_uniq = list(set(check3))
        #print check3_uniq

        counter = 0
        itmpsum0 = 0
        itmpsum1 = 0
        itmpsum2 = 0

        for i in check3_uniq:

            tmprand = random.randint(1,20)

            if tmprand % 20 == 0:

                i2 = i.replace("(","").replace(")","")
                itmp = i2.split(",")
                #print itmp
                
                try:
                    itmpsum0 = itmpsum0 + float(itmp[0])
                    itmpsum1 = itmpsum1 + float(itmp[1])
                    itmpsum2 = itmpsum2 + float(itmp[2])
                except:
                    pass

            counter = counter + 1

        #print "itmpsum0:" + str(itmpsum0)
        #print "itmpsum1:" + str(itmpsum1)
        #print "itmpsum2:" + str(itmpsum2)
        #print "len:" + str(len(check3_uniq))

        avg1 = itmpsum0/len(check3_uniq)
        avg2 = itmpsum1/len(check3_uniq)
        avg3 = itmpsum2/len(check3_uniq)

        # magic number is 12.
        #check4 = check3_uniq[12].replace("(","").replace(")","")
        #tmp2 = check4.split(",")
        
        #print line.strip()
        #print tmp[0] + "," + tmp[1] + "," + tmp2[1] + "," + tmp2[2] + "," + tmp2[3]
        print tmp[0] + "," + tmp[1] + "," + str(avg1) + "," + str(avg2) + "," + str(avg3)

    else:
        print line.strip()

    line = f.readline()

f.close()


