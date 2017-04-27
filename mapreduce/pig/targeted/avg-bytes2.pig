alarm = LOAD '$SRCT' USING PigStorage(',') AS (targeted_alarm_id:int, capture_time:chararray, src_university_id:int, dest_university_id:int, mail_send_status:chararray ,subtype:chararray, generated_time:chararray, source_ip:chararray, src_country_code:chararray, destination_ip:chararray, dest_country_code:chararray, rule_name:chararray,source_user:chararray, destination_user:chararray, application:chararray, virtual_system:chararray, source_zone:chararray, destination_zone:chararray, log_forwarding_profile:chararray, repeat_cnt:int,source_port:int,destination_port:int, flags:chararray, protocol:chararray, action:chararray, alarm_name:chararray, threat_id:int, category:chararray, severity:int, direction:chararray, source_location:chararray, destination_location:chararray, content_type:chararray, file_digest:chararray, user_agent:chararray, file_type:chararray, x_forwarded_for:chararray, src_university_name:chararray, dest_university_name:chararray);  

session = LOAD '$SRCS' USING PigStorage(',') AS (session_id:int,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:int,bytes_sent:int,bytes_received:int,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:int,dest_university_name:chararray);

filtered_alarm = FILTER alarm BY severity > 300;
filtered_alarm_group = GROUP filtered_alarm all;                                     

addrpair = FOREACH filtered_alarm_group GENERATE                                                         
	filtered_alarm.destination_ip as destination_ip,
	filtered_alarm.source_ip as source_ip;

addrpair_distinct = DISTINCT addrpair;

session_group = GROUP session all;

session_ip  = FOREACH session_group GENERATE							
       	  	  group as label,
		  session.source_ip as source_ip,                                                                
		  session.destination_ip as destination_ip,                                                     
		  AVG(session.bytes) as avrbytes;

alert_join = JOIN
	   addrpair_distinct BY filtered_alarm.source_ip,
	   session_ip BY session.source_ip;

STORE alert_join INTO 'avg-bytes2.dump';