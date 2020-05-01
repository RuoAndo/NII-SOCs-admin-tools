# -*- coding: utf-8 -*-

import xml.etree.ElementTree as ET 
from xml.sax.saxutils import unescape
import sys
args = sys.argv

tree = ET.parse(args[1]) 

root = tree.getroot()

#for name in root.iter('dashboard'):
#print(name.text)

#print("<dashboard>")      
#print("<label>test2</label>")    
    
flag = 0

for child in root:
    #print(child.tag)
    #print(child.attrib)

    for child2 in child:
        #print(child2.tag)
        #print(child2.attrib)

        for child3 in child2:
            #print(child3.tag)
            #print(child3.text)

            if 'PORT 25' in child3.text:
                
                flag = 1;
                flag2 = 0;

                print("<row>") 
                print("<panel>")    

                for child3 in child2:

                    if 'table' not in child3.tag and 'chart' not in child3.tag: 
                       print("<" + child3.tag + ">" + child3.text.encode('utf_8').strip().replace(">","&gt;").replace("<","&lt;") + "</" + child3.tag + ">")
                       flag2 = 0

                    elif 'chart' in child3.tag and  'table' not in child3.tag: 
                       #print("<" + child3.tag + ">" + child3.text.encode('utf_8').strip().replace(">","&gt;").replace("<","&lt;") + "</" + child3.tag + ">")
                       flag2 = 1


                    for child4 in child3:
 
                        if flag == 1 and flag2 ==0:
                            print("<table>")  
                            print("<search>")  
                            for child5 in child4:
                                print("<" + child5.tag + ">" + child5.text.strip().replace(">","&gt;").replace("<","&lt;") + "</" + child5.tag + ">")

                            flag =0
                            print("</search>")
                            print("<option name=\"count\">20</option>")
                            print("<option name=\"dataOverlayMode\">none</option>")
                            print("<option name=\"drilldown\">none</option>")
                            print("<option name=\"percentagesRow\">false</option>")
                            print("<option name=\"rowNumbers\">false</option>")
                            print("<option name=\"totalsRow\">false</option>")
                            print("<option name=\"wrap\">true</option>")
                            print("</table>")

                            print("</panel>")    
                            print("</row>") 
 
                        if flag == 1 and flag2 == 1:
                            print("<chart>")  
                            print("<search>")  
                            for child5 in child4:
                                print("<" + child5.tag + ">" + child5.text.strip().replace(">","&gt;").replace("<","&lt;") + "</" + child5.tag + ">")

                            flag =0
                            print("</search>")
                            print("<option name=\"count\">20</option>")
                            print("<option name=\"dataOverlayMode\">none</option>")
                            print("<option name=\"drilldown\">none</option>")
                            print("<option name=\"percentagesRow\">false</option>")
                            print("<option name=\"rowNumbers\">false</option>")
                            print("<option name=\"totalsRow\">false</option>")
                            print("<option name=\"wrap\">true</option>")
                            print("</chart>")

                            print("</panel>")    
                            print("</row>") 


#print("</dashboard>")      

#tree.write('test2.xml', encoding='UTF-8')
