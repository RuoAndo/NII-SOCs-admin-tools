import concurrent.futures
import time
import mpu
import geoip2.database
import os

from haversine import haversine, Unit

def test(x):

    reader = geoip2.database.Reader('GeoLite2-City.mmdb')
    
    dnsiplist = []  

    file_dns=str(x)
    
    with open(file_dns) as f:
        
        for line in f:
            dnsiplist.append(line.strip()) 

    f.close()

    file_gs = "gs.txt"  
    wfilename = str(x) + ".dis"

    os.remove(wfilename)
    fw = open(wfilename, 'a')

    counter = 0
    
    with open(file_gs) as f2:
        
        reader2 = geoip2.database.Reader('GeoLite2-City.mmdb')
        for line2 in f2:

            print(line2.strip())
            
            response = reader.city(line2)
           
            for ip in dnsiplist:
                 #print(ip)

                try:
                    
                    response2 = reader.city(ip)

                    lyon = (response2.location.latitude, response2.location.longitude) # (lat, lon)
                    paris = (response.location.latitude, response.location.longitude) # (lat, lon)

                    #print(haversine(lyon, paris))
                    fw.write(str(line2.strip())+","+str(ip)+","+str(haversine(lyon, paris))+"\n")

                    counter = counter + 1



                    
                except:
                    pass


                if counter % 1000000 == 0:
                    print(counter + "  - done.")
                
                

        reader2.close()

        print(counter)
        
    f2.close()
    fw.close()        

    reader.close()
    
       
#a=[100,101,102,103,104,105,106,107,108,109]
a=[100]

with concurrent.futures.ThreadPoolExecutor(max_workers=3) as executor:
    for i in a:
        executor.submit(test,i)
