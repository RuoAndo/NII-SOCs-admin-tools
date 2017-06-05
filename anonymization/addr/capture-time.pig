REGISTER piggybank.jar;
REGISTER addr.jar;
REGISTER date.jar;

session = LOAD '$SRCS' USING PigStorage(',') AS (session_id:int,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:int,bytes_sent:int,bytes_received:int,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:int,dest_university_name:chararray);

-- records_group = GROUP records BY source_ip;
-- dump records_group

s = FOREACH session GENERATE
      session_id as sid,
      capture_time as ct,
      destination_ip as dip,
      source_ip as sip,
      bytes_sent as bs,
      bytes_received as br;

s_filtered = FILTER s BY (sip MATCHES '.\\d+\\.\\d+\\.\\d+\\.\\d+') OR (dip MATCHES '.\\d+\\.\\d+\\.\\d+\\.\\d+'); 

filtered = FOREACH s_filtered GENERATE
      date.DATE(ct) as ct;
      
dump filtered;
STORE filtered INTO 'stmp';

two = LOAD 'stmp/part-m-00000' USING PigStorage(',') AS (ct:long);
--dump two;

grouped = GROUP two ALL;
-- dump grouped;

avg = FOREACH grouped GENERATE
      	      AVG(two.ct) as ct_avg;

-- dump avg;

crossed = CROSS avg, filtered;

crossed_ordered = ORDER crossed BY $1 ASC;
-- dump crossed_ordered;

crossed_filtered = FOREACH crossed_ordered GENERATE
	 $0,
	 $1,
	 (double)$1 - (double)$0;

dump crossed_filtered;

