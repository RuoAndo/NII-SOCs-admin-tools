REGISTER date.jar;
REGISTER addr.jar;

session = LOAD '$SRCS' USING PigStorage(',') AS (session_id:long,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:int,bytes_sent:int,bytes_received:int,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:chararray,dest_university_name:chararray);

P = FOREACH session GENERATE      
		   session_id as sid,
		   capture_time as ct,                             
	   	   destination_ip as dip,
		   source_ip as sip,
		   bytes as bytes;

Q = FILTER P BY (sip MATCHES '.\\d+\\.\\d+\\.\\d+\\.\\d+') OR (dip MATCHES '.\\d+\\.\\d+\\.\\d+\\.\\d+'); 

QF = FOREACH Q GENERATE
      sid as sid,
      date.DATE(ct) as ct,
      addr.ADDR(dip) as dip,
      addr.ADDR(sip) as sip,
      bytes as bytes;

-- dump QF;

QFO = ORDER QF by dip;

dump QFO;


