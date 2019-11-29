
# indexer setting

<pre>
2045  ./splunk edit cluster-config -mode slave -master_uri https://XXX.XXX.XXX.XXX:8089 -replication_port 9200 -secret XXXXXXX
2048  ./splunk edit licenser-localslave -master_uri https://XXX.XXX.XXX.XXX:8089 -auth admin:XXXXXXXX
</pre>