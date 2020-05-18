import sys
args = sys.argv

f = open(args[1], 'r')
line = f.readline()

a = []
h = []

while line:
    if "source" in line:
        tmp = line.split("source")
        tmp2 = tmp[1].split("host")
        tmpstr = tmp2[0]
        a.append(tmpstr[:-2].strip("=").lstrip("\"").rstrip("\""))        
        h.append(tmp2[1][:-2].strip("=").lstrip("\"").rstrip("\""))

    #else:
        #print(line.strip())

    line = f.readline()
f.close()

s = set(a)
hh = set(h)

#print s
#print hh

f = open(args[1], 'r')
line = f.readline()

egress_flag = 0
ingress_flag = 0
host_flag = 0

while line:

    if "<label>" in line:
        line = "<label>NNNNN</label>"

    egress_flag = 0
    ingress_flag = 0

    done_flag_host = 0
    done_flag_ingress = 0
    done_flag_egress = 0

    for rs in s:

        if "ingress" in rs:
            replaced = line.replace(rs,"IIIII").strip()
        
        if "egress" in rs:
            replaced = replaced.replace(rs,"EEEEE").strip()

    for hhh in hh:
            replaced = replaced.replace(hhh,"HHHHH").strip()


    print replaced

    #if host_flag == 1:
    #    print line.replace(hhh,"HHHHH").strip()
        #continue

    #if done_flag == 0 and done_flag_2 == 0:
    #    print replaced
        #print line.strip()

    line = f.readline()
f.close()

