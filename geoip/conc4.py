import concurrent.futures
import time
import mpu
import geoip2.database
import os
import datetime
from haversine import haversine, Unit

reader = geoip2.database.Reader('GeoLite2-City.mmdb')

def test(x):

    dnsiplist = []  

    file_gs= "gs.txt"  

    with open(file_gs) as f:
    
        for line in f:
            dnsiplist.append(line.strip()) 
        
    f.close()

    rfilename = str(x)
    wfilename = str(x) + ".dis"

    try:
        os.remove(wfilename)
    except:
        pass
    
    for ip in dnsiplist:
            
        distance = 100000000000000
        nearest_ip = ""
    
        response = reader.city(ip)

        print(ip)
        print("open " + rfilename)

        counter = 0
        with open(rfilename) as rf:
            
            for line2 in rf:

                #reader2 = geoip2.database.Reader('GeoLite2-City.mmdb')

                counter = counter + 1
                #print(counter)

                now = datetime.datetime.now()            

                if counter % 100000 == 0:
                    print("[" + str(now) + "][" +str(x) + "] " + str(counter) + " lines done." )

            
                try:
                    response2 = reader.city(line2.strip())
                except:
                    continue
                
                try:

                    paris = (response.location.latitude, response.location.longitude) # (lat, lon)
                    lyon = (response2.location.latitude, response2.location.longitude) # (lat, lon)

                    if float(distance) > float(haversine(lyon, paris)):
                        #fw = open(wfilename, 'a')
                        #fw.write(str(ip)+","+str(line2.strip())+","+str(haversine(lyon, paris))+"\n")
                        #fw.close()        

                        now = datetime.datetime.now()            
                        print("[" + str(now) + "][" + str(x) + "] UPDATE:" + str(ip)+","+str(line2.strip())+","+str(haversine(lyon, paris))+" at line:" + str(counter) )

                        nearest_ip = line2.strip()
                        distance = haversine(lyon, paris) 
                        
                           
                except:
                    continue

                    #reader2.close()

        now = datetime.datetime.now()            

        fw = open(wfilename, 'a')
        fw.write(str(ip)+","+str(line2.strip())+","+str(haversine(lyon, paris))+"\n")
        fw.close()
    
        print("["+str(now)+"]"+" COMMIT: "+str(ip)+","+str(nearest_ip)+","+str(haversine(lyon, paris)))
    
        print("close " + rfilename)
        rf.close()    

#a=[100,101,102,103,104,105,106,107,108,109]
a=list(range(100, 150))
#a=[100]

with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
    for i in a:
        executor.submit(test,i)
           
reader.close()
    
       
