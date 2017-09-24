session = LOAD '$SRCS' USING PigStorage(',') AS (session_id:long,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:int,bytes_sent:int,bytes_received:int,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:chararray,dest_university_name:chararray);

P = FOREACH session GENERATE      
		   session_id as sid,
		   capture_time as ct,                             
	   	   destination_ip as dip,
		   source_ip as sip,
		   bytes as bytes;
-- dump P

A = LOAD '1.csv' USING PigStorage(',') AS (cluster:int, dipa:chararray, sipa:chararray, bytes:long, sid:long);

SPLIT A INTO
      A_error IF sid is null,
      A_SPL IF sid is not null;

-- J = join P by (dip, sip) LEFT OUTER, A_SPL by (dipa, sipa); 

J = join P by dip, A_SPL by dipa; 
--dump J

JJ = join J by $3, A_SPL by sipa; 
-- dump JJ;

JJF = FOREACH JJ GENERATE
      	      $0,
	      $1,
	      $2,
	      $3;

dump JJF;

--SPLIT JJ INTO
--      JJ_error IF dipa is null,
--      JJ_SPL IF dipa is not null;

--dump JJ_SPL
--STORE JJ_SPL INTO 'anomaly' USING PigStorage(',');
