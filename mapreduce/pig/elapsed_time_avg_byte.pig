%default SRCS 'session_0305_1000.csv'
session = LOAD '$SRCS' USING PigStorage(',') AS (session_id:int,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:int,bytes_sent:int,bytes_received:int,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:int,dest_university_name:chararray);

filtered_session = FILTER session BY elapsed_time != '' AND destination_ip == '$IP';
dump filtered_session 
STORE filtered_session INTO '$DUMP.dump';

filtered_session_all = Group filtered_session;
filtered_session_avg = foreach filtered__session_all generate filtered_session.destination_ip, AVG(filtered_session.bytes);
-- dump filtered_records;
-- dump records_bytes_avg
STORE filtered_session_avg INTO 'elapsed_time_avg_byte.dump';

-- dump records
-- STORE records INTO 'targeted.dump';
-- alert_join = JOIN
--  targeted BY source_ip,
--  session BY source_ip
--  ;
--STORE alert_join INTO 'join.dump';