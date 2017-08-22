session = LOAD '$SRCS' USING PigStorage(',') AS (session_id:long,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:double,bytes_sent:double,bytes_received:double,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:int,dest_university_name:chararray);

SF = FOREACH session GENERATE                                    
                   destination_ip,
                   source_ip,
                   destination_port,
                   source_port,
		   bytes_sent,
		   bytes_received,
		   session_id;

-- PF = FILTER SF BY (source_port == 25) OR (destination_port == 25);
PF = FILTER SF BY (destination_port == 25);

dump PF;
STORE PF INTO 'spam-PF' USING PigStorage(',');
