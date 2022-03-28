import concurrent.futures
import time
import mpu

def test(x):
    with open('./gs.out') as f:

        for line in f:

            rfilename = str(x) + ".out"
            wfilename = str(x) + ".dis"

            fw = open(wfilename, 'w')
            
            with open(rfilename) as f2:
                for line2 in f2:
                
                    tmp = line.split(",")
                    tmp2 =line2.split(",")

                    dist = mpu.haversine_distance((float(tmp[1]),float(tmp[2])), (float(tmp2[1]), float(tmp2[2])))
                    result = str(tmp[0])+","+str(tmp2[0])+","+str(dist)+"\n"

                    fw.write(result)

            fw.close()        
            f2.close()
        f.close()
        

a=[100,101,102,103,104,105,106,107,108,109]

with concurrent.futures.ThreadPoolExecutor(max_workers=3) as executor:
    for i in a:
        executor.submit(test,i)
