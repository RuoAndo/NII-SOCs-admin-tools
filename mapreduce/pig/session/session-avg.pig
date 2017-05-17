session = LOAD '$SRCS' USING PigStorage(',') AS (session_id:int,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:int,bytes_sent:double,bytes_received:double,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:int,dest_university_name:chararray);

session_group = GROUP session BY dest_university_id; 

-- dump session_group;

avg = FOREACH session_group GENERATE
      group as label,
      AVG(session.bytes_sent) as avg_sent,
      AVG(session.bytes_received) as avg_received;
      -- session.bytes_received as avg;
      -- bytes_sent -  bytes_received as diff,
      -- bytes_sent as sent,
      -- bytes_received as received,
      -- capture_time as time,
      -- source_ip as sip,
      -- dest_university_id as did;

-- dump avg;

session_cross = cross avg, session;

-- dump session_cross

diff = FOREACH session_cross GENERATE
       	    label,
	    capture_time, 
       	    bytes_sent - avg_sent,
            bytes_received - avg_received,
	    dest_university_nane;

dump diff;