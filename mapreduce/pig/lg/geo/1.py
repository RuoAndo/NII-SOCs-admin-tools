import sys
import re

argvs = sys.argv
argc = len(argvs)
f = open(argvs[2]) 

line = f.readline() 

ipList = []
aList = []

while line:
    #print line
    tmp = line.split(",")
    ipList.append(tmp[1].strip())
    aList.append(tmp[0])
    line = f.readline() 
f.close()

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

#print aList

line = f.readline() 

counter = 1
while line:

    try:
        tmp = line.split(",")
        tmp2 = tmp[1].split(":")

        #print tmp

        counter = 0
        for i in ipList:
            if i == tmp[10].strip():
                

                if 'Tor' in aList[counter]:
                    #print "HIT:" + aList[counter] + ":" + str(counter)
                    print "<Style id=\"msn_ylw-pushpin1300\">";
                    print "<IconStyle>";
                    print "<color>ff00ffff</color>";
                    #print "<color>ff00ff00</color>";
                    print "<scale>12</scale>";
                    print "</IconStyle>";
                    print "<LabelStyle>";
                    print "<color>ff00ffff</color>";
                    print "<scale>12</scale>";
                    print "</LabelStyle>";
                    print "</Style>";

                    print "<Placemark>";
                    print "<name>" + str(counter) + ":" +  tmp2[1].strip()  + "</name>";
                    print "<description>" + tmp2[1].strip() + "</description>";
                    print "<styleUrl>#msn_ylw-pushpin1300</styleUrl>";
                    print "<Point>";
                    print "<coordinates>" + tmp[7].strip() + "," + tmp[6].strip() + "</coordinates>";
                    print "</Point>";
                    print "</Placemark>";


                elif 'SINKHOLE' in aList[counter]:
                    #print "HIT:" + aList[counter] + ":" + str(counter)
                    print "<Style id=\"msn_ylw-pushpin1300\">";
                    print "<IconStyle>";
                    print "<color>ffff0000</color>";
                    print "<scale>12</scale>";
                    print "</IconStyle>";
                    print "<LabelStyle>";
                    print "<color>ffff0000</color>";
                    print "<scale>12</scale>";
                    print "</LabelStyle>";
                    print "</Style>";

                    print "<Placemark>";
                    print "<name>" + str(counter) + ":" +  tmp2[1].strip()  + "</name>";
                    print "<description>" + tmp2[1].strip() + "</description>";
                    print "<styleUrl>#msn_ylw-pushpin1300</styleUrl>";
                    print "<Point>";
                    print "<coordinates>" + tmp[7].strip() + "," + tmp[6].strip() + "</coordinates>";
                    print "</Point>";
                    print "</Placemark>";

                elif 'Darknet' in aList[counter]:
                    #print "HIT:" + aList[counter] + ":" + str(counter)
                    print "<Style id=\"msn_ylw-pushpin1300\">";
                    print "<IconStyle>";
                    print "<color>ff800080</color>";
                    print "<scale>12</scale>";
                    print "</IconStyle>";
                    print "<LabelStyle>";
                    print "<color>ff800080</color>";
                    print "<scale>12</scale>";
                    print "</LabelStyle>";
                    print "</Style>";

                    print "<Placemark>";
                    print "<name>" + str(counter) + ":" +  tmp2[1].strip()  + "</name>";
                    print "<description>" + tmp2[1].strip() + "</description>";
                    print "<styleUrl>#msn_ylw-pushpin1300</styleUrl>";
                    print "<Point>";
                    print "<coordinates>" + tmp[7].strip() + "," + tmp[6].strip() + "</coordinates>";
                    print "</Point>";
                    print "</Placemark>";

                else:

                    print "<Style id=\"msn_ylw-pushpin1300\">";
                    print "<IconStyle>";
                    print "<color>ff0000ff</color>";
                    print "<scale>12</scale>";
                    print "</IconStyle>";
                    print "<LabelStyle>";
                    print "<color>ff0000ff</color>";
                    print "<scale>12</scale>";
                    print "</LabelStyle>";
                    print "</Style>";

                    print "<Placemark>";
                    print "<name>" + str(counter) + ":" +  tmp2[1].strip()  + "</name>";
                    print "<description>" + tmp2[1].strip() + "</description>";
                    print "<styleUrl>#msn_ylw-pushpin1300</styleUrl>";
                    print "<Point>";
                    print "<coordinates>" + tmp[7].strip() + "," + tmp[6].strip() + "</coordinates>";
                    print "</Point>";
                    print "</Placemark>";

            else:
                
                if len(tmp[1]) < 12:

                    print "<Style id=\"msn_ylw-pushpin1300\">";
                    print "<IconStyle>";
                    print "<color>ff00ff00</color>";
                    print "<scale>3</scale>";
                    print "</IconStyle>";
                    print "<LabelStyle>";
                    print "<color>ff0000ff</color>";
                    print "<scale>3</scale>";
                    print "</LabelStyle>";
                    print "</Style>";

                    print "<Placemark>";
                    print "<name>" + str(counter) + ":" +  tmp2[1].strip()  + "</name>";
                    print "<description>" + tmp2[1].strip() + "</description>";
                    print "<styleUrl>#msn_ylw-pushpin1300</styleUrl>";
                    print "<Point>";
                    print "<coordinates>" + tmp[7].strip() + "," + tmp[6].strip() + "</coordinates>";
                    print "</Point>";
                    print "</Placemark>";

            counter = counter + 1

    except:
        pass

    counter  = counter + 1
    line = f.readline()

print "</Folder>";
print "</Document>";
print "</kml>";
