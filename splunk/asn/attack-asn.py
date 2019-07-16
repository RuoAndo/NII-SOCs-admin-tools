import pyasn
import datetime
import sys
args = sys.argv

f = open(args[1], 'r')
line = f.readline()
line = f.readline()

asndb = pyasn.pyasn('asn_file')

#print("timestamp, ipaddr, ASN, mask")
while line:
    #print(line)
    tmp = line.split(",")
    ipaddr = tmp[0].strip("\"")
    #print(str)

    result = asndb.lookup(ipaddr)
    #result2 = "".join(map(str, result))
    result2 = str(result).strip("\)").strip("\(")
    print(str(datetime.datetime.today()) + "," + ipaddr + "," + result2)

    line = f.readline()

f.close()
