#import geoip2.database
#reader = geoip2.database.Reader('GeoLite2-City.mmdb')
#import geopy.distance
import mpu

with open('./gs.out') as f:

    for line in f:
        
        with open('./100.out') as f2:
            for line2 in f2:
                
                tmp = line.split(",")
                tmp2 = line2.split(",")

                dist = mpu.haversine_distance((float(tmp[1]),float(tmp[2])), (float(tmp2[1]), float(tmp2[2])))
                #print(str(tmp[0])+","+str(tmp2[0])+","+str(float(tmp2[1]))+","+str(float(tmp2[2]))+","+str(dist))
                print(str(tmp[0])+","+str(tmp2[0])+","+str(dist))
               

            f2.close()
f.close()

