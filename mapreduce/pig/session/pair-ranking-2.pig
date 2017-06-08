sessions = LOAD '$SRCS' USING PigStorage(',') AS (session_id:long,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:int,bytes_sent:int,bytes_received:int,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:int,dest_university_name:chararray);
         
session_filtered = FOREACH sessions GENERATE
	session_id as session_sessionid,
	source_ip as session_sourceip;
--dump session_filtered;
--STORE session_filtered_group INTO 'stmp';

session_filtered_group = GROUP session_filtered by session_sourceip;
--dump session_filtered_group;
--STORE session_filtered_group INTO 'stmp';

session_group = FOREACH session_filtered_group GENERATE
	      COUNT(session_filtered.session_sessionid) as sidcount,
	      FLATTEN(session_filtered.session_sourceip);
--dump session_group;
--STORE session_group INTO 'stmp';

ordered_session_group = ORDER session_group BY sidcount DESC;
--dump ordered_session_group;
STORE ordered_session_group INTO 'tmp-osg' USING PigStorage(',');



