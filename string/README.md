<pre>
tshark -r dns_00001_20171106105100.pcap -E separator=',' -T fields -e ip.src -e ip.dst -e dns.qry.name -e dns.ns -e dns.ptr.domain_name > dump-string
timeout 5 python 1.py iplist dump-string > tmp
</pre>

