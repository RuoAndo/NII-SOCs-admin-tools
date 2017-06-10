REGISTER addr.jar;
REGISTER date.jar;

session = LOAD '$SRCS' USING PigStorage(',') AS (session_id:long,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:double,bytes_sent:double,bytes_received:double,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:int,dest_university_name:chararray);

s = FOREACH session GENERATE
      session_id as sid,
      capture_time as ct,
      destination_ip as dip,
      source_ip as sip,
      bytes as bytes;

-- 2001:df0:2ed:1213::136
-- 163.209.21.158,61.205.70.161

s_filtered = FILTER s BY (sip MATCHES '.\\d+\\.\\d+\\.\\d+\\.\\d+') OR (dip MATCHES '.\\d+\\.\\d+\\.\\d+\\.\\d+'); 

S = FOREACH s_filtered GENERATE
      sid,
      date.DATE(ct),
      addr.ADDR(dip),
      addr.ADDR(sip),
      bytes;

-- dump s_addr;
STORE S INTO 'tmp-s' USING PigStorage(',');


