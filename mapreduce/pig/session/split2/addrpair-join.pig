session = LOAD '$SRCS' USING PigStorage(',') AS (session_id:long,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:int,bytes_sent:long,bytes_received:long,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:chararray,dest_university_name:chararray);

P = FOREACH session GENERATE                                    
	   	   destination_ip as dip,
		   source_ip as sip,
		   session_id as sid,
		   bytes_sent as bytes_sent,
		   bytes_received as bytes_received;

A = LOAD 'addrpair' USING PigStorage(',') AS (dip:chararray, sip:chararray);

J = join P by (dip, sip) LEFT OUTER, A by (dip, sip); 
-- dump J;
STORE J INTO 'addrpair-join' USING PigStorage(',');
