records = LOAD '$SRCS' USING PigStorage(',') AS (targeted_alarm_id:int, capture_time:chararray, src_university_id:int, dest_university_id:int, mail_send_status:chararray ,subtype:chararray, generated_time:chararray, source_ip:chararray, src_country_code:chararray, destination_ip:chararray, dest_country_code:chararray, rule_name:chararray,source_user:chararray, destination_user:chararray, application:chararray, virtual_system:chararray, source_zone:chararray, destination_zone:chararray, log_forwarding_profile:chararray, repeat_cnt:int,source_port:int,destination_port:int, flags:chararray, protocol:chararray, action:chararray, alarm_name:chararray, threat_id:int, category:chararray, severity:int, direction:chararray, source_location:chararray, destination_location:chararray, content_type:chararray, file_digest:chararray, user_agent:chararray, file_type:chararray, x_forwarded_for:chararray, src_university_name:chararray, dest_university_name:chararray);  

-- dump records

-- filtered_records = FILTER records BY session_end_reason == 'unknown';

filtered_records = FILTER records BY severity == 400;
dump filtered_records

-- records_group = GROUP records BY ;                                     
-- addrpair = FOREACH records_group GENERATE                                                         
--	records.destination_ip as destip,
--	records.source_ip as sourceip;
-- dump addrpair
-- addrpair_distinct = DISTINCT addrpair;
-- dump addrpair_distinct
-- STORE addrpair_distinct INTO '$SRCS.dump';
-- dump filtered_records;
-- STORE filtered_records INTO 'tmp.txt';
-- filtered_records_all = Group filtered_records All;
-- records_bytes_avg = foreach filtered_records_all generate filtered_records.session_id, AVG(filtered_records.bytes);
-- dump filtered_records;
-- dump records_bytes_avg
