%default SRCS 'SESSION_20170410_2100-20170410_2200.csv'

session = LOAD '$SRCS' USING PigStorage(',') AS (session_id:int,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:int,bytes_sent:int,bytes_received:int,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:chararray,dest_university_name:chararray);

-- filtered_records = FILTER records BY session_end_reason == 'unknown';

session_group = GROUP session BY session_id;                                     

addrpair = FOREACH session_group GENERATE                                                         
	group as label,
	session.destination_ip as destip,
	session.source_ip as sourceip,
	session.dest_university_name as destuniv,
	session.src_university_name as srcuniv;

addrpair_distinct = DISTINCT addrpair;
STORE addrpair_distinct INTO 'addrpair.dump';

-- dump filtered_records;
-- STORE filtered_records INTO 'tmp.txt';

-- filtered_records_all = Group filtered_records All;
-- records_bytes_avg = foreach filtered_records_all generate filtered_records.session_id, AVG(filtered_records.bytes);
-- dump filtered_records;
-- dump records_bytes_avg