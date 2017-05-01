records = LOAD '$SRCS' USING PigStorage(',') AS (session_id:int,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:int,bytes_sent:int,bytes_received:int,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:int,dest_university_name:chararray);

-- records_group = GROUP records BY session_id;
records_group = GROUP records all;

addrpair = FOREACH records_group GENERATE                                                         
	flatten(records.destination_ip) as dest_ip,
	flatten(records.source_ip) as source_ip;
	-- flatten(records.bytes) as bytes;

addrpair_distinct = DISTINCT addrpair;
-- dump addrpair_distinct

avg = FOREACH records_group GENERATE
	flatten(records.destination_ip) as destip,
	flatten(records.bytes) as bytes;
	

-- dump addrpair_distinct

alert_join = JOIN
	addrpair_distinct BY dest_ip,
	avg BY destip;

-- dump alert_join;

alert_filtered = FILTER alert_join BY bytes > 10000;
dump alert_filtered;

-- center = FOREACH alert_group GENERATE
--       alert_join.dest_ip as destip,
--       AVG(alert_join.bytes) as avgbytes;

-- dump center;

--;

--dump center