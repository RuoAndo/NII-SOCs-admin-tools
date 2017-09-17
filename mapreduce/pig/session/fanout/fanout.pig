REGISTER piggybank.jar;
DEFINE POW org.apache.pig.piggybank.evaluation.math.POW();

session = LOAD '$SRCS' USING PigStorage(',') AS (session_id:long,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:double,bytes_sent:double,bytes_received:double,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:int,dest_university_name:chararray);

abs = FOREACH session GENERATE
      session_id,
      capture_time,
      destination_ip,
      source_ip,
      source_port,
      destination_port,
      bytes_sent,
      bytes_received;
  
-- dump abs;

session_group = GROUP abs BY source_ip; 

avg = FOREACH session_group GENERATE
      group as avg_label,
      abs.destination_ip as avg_destination_ip,
      abs.source_port as avg_source_port,
      abs.destination_port as avg_destination_port,
      abs.bytes_sent,
      abs.bytes_received;

-- dump avg;

fanout = FOREACH avg GENERATE
	avg_label,
	-- avg_destination_ip,
	COUNT(avg_destination_ip) as fcount;
        
dump fanout;

-- fanout_sorted = ORDER fanout BY fcount DESC;
-- limit_fanout_sorted = LIMIT fanout_sorted 10;
-- dump limit_fanout_sorted;
-- STORE limit_fanout_sorted INTO '$LOGDATE.dump';  