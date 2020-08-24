import xml.etree.ElementTree as ET

import sys
args = sys.argv
argc = len(args) 

if (argc != 2):  
    print("Usage: ./xml-azure.py [XML File]")
    quit()

tree = ET.parse(args[1])
root = tree.getroot()


#print(root.tag)
#print(root.attrib)

for child in root:
    print(child.attrib["Name"])

    for chind in child:

        tmp =  str(chind.attrib).split(" ")
        tmp2 = tmp[1].replace("'","").strip("}").replace("/",",")
        
        #print(str(child.attrib["Name"]) + "," + tmp2)
        print(tmp2)
        #print(child.attrib["name"],child.find("rank").text)
        #print(chind.attrib)
		
