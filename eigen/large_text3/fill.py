import sys 
import commands

argvs = sys.argv  
argc = len(argvs) 

f = open(argvs[1])

line = f.readline() 


while line:
    tmp = line.split(",")
    #print tmp

    if int(tmp[0]) == 0:

        try:
            check = commands.getoutput("./avg-random.sh all2")
            check = commands.getoutput("tail c")
            #print check

            # 0,2.0887825631173933E9,2446.4737010861577,70445.28836622089
            tmp2 = check.split(",")
        
            comstr = str(tmp[0]) + "," + str(tmp[1]) + "," + str(tmp2[2]) + "," + str(tmp2[3]) + "," + str(tmp2[1])
            print comstr.replace("\n","")

        except:
            check = commands.getoutput("./avg-random.sh all2")
            check = commands.getoutput("tail c")
            #print check

            # 0,2.0887825631173933E9,2446.4737010861577,70445.28836622089
            tmp2 = check.split(",")
        
            comstr = str(tmp[0]) + "," + str(tmp[1]) + "," + str(tmp2[2]) + "," + str(tmp2[3]) + "," + str(tmp2[1])
            print comstr.replace("\n","")

    else:
        print tmp[0] + "," + tmp[1] + "," + tmp[2] + "," + tmp[3] + "," + tmp[4].strip()


    line = f.readline() 
