import geoip2.database
import json

import sys

args = sys.argv

with geoip2.database.Reader('GeoLite2-City.mmdb') as reader:
	response = reader.city(args[1])
	#latlong = str(response.location.latitude) + "," + str(response.location.longitude)
	latlong = str(response.location.longitude) + "," + str(response.location.latitude)
	print(latlong)
	

	
