import sys
import re

argvs = sys.argv
argc = len(argvs)
f = open(argvs[1]) 

print "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";

print "<kml xmlns=\"http://www.opengis.net/kml/2.2\"";
print " xmlns:gx=\"http://www.google.com/kml/ext/2.2\"";
print " xmlns:kml=\"http://www.opengis.net/kml/2.2\" ";
print " xmlns:atom=\"http://www.w3.org/2005/Atom\">";

print "<Document>";
print "<name>";
#print $dt->strftime('%Y/%m/%d %H:%M:%S');
print "</name>";
print "<Folder>";
print "<Style id=\"msn_ylw-pushpin1300\">";
print "<IconStyle>";
print "<color>ff0000ff</color>";
print "<scale>3</scale>";
print "</IconStyle>";
print "<LabelStyle>";
print "<color>ff0000ff</color>";
print "<scale>3</scale>";
print "</LabelStyle>";
print "</Style>";

line = f.readline() 

counter = 1
while line:

    try:
        tmp = line.split(",")
        tmp2 = tmp[1].split(":")

        if len(tmp[1]) < 12:
        
           print "<Placemark>";
           print "<name>" + str(counter) + ":" +  tmp2[1].strip()  + "</name>";
           print "<description>" + tmp2[1].strip() + "</description>";
           print "<styleUrl>#msn_ylw-pushpin1300</styleUrl>";
           print "<Point>";
           print "<coordinates>" + tmp[5].strip() + "," + tmp[6].strip() + "</coordinates>";
           print "</Point>";
           print "</Placemark>";

    except:
        pass

    counter  = counter + 1
    line = f.readline()

print "</Folder>";
print "</Document>";
print "</kml>";
