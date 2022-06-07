import concurrent.futures
import time
import mpu
import geoip2.database
import os
import datetime

from haversine import haversine, Unit

reader = geoip2.database.Reader('GeoLite2-City.mmdb')
    
dnsiplist = []  

file_gs= "gs.txt"  

with open(file_gs) as f:
    
    for line in f:
        dnsiplist.append(line.strip()) 
        
f.close()

rfilename = "100"
wfilename = "100" + ".dis"

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
                print("[" + str(now) + "] " + str(counter) + " lines done." )

            
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
                    print("[" + str(now) + "] UPDATE:"+str(ip)+","+str(line2.strip())+","+str(haversine(lyon, paris)))

                    nearest_ip = line2.strip()
                    distance = haversine(lyon, paris) 
                        
                           
            except:
                continue

            #reader2.close()


    now = datetime.datetime.now()            

    fw = open(wfilename, 'a')
    fw.write(str(ip)+","+str(line2.strip())+","+str(haversine(lyon, paris))+"\n")
    fw.close()
    
    print("["+str(now)+"]"+" COMMIT: "+str(nearest_ip)+","+str(line2.strip())+","+str(haversine(lyon, paris)))
    
    print("close " + rfilename)
    rf.close()    

reader.close()
    
       
