records = LOAD '$SRCS' USING PigStorage(',') AS (session_id:int,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:int,bytes_sent:int,bytes_received:int,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:int,dest_university_name:chararray);

records_group = GROUP records BY session_id;                                     

addrpair = FOREACH records_group GENERATE                                                         
	flatten(records.destination_ip) as destip,
	flatten(records.source_ip) as sourceip;


addrpair_distinct = DISTINCT addrpair;
-- dump addrpair_distinct
-- STORE addrpair_distinct INTO '$SRCS.dump';

match = JOIN
      addrpair_distinct by sourceip,
      records by source_ip;

filtered_match = FILTER match BY dest_university_id == $UID;

dump filtered_match

--match_group = GROUP match all;

--center = FOREACH match_group GENERATE
--     match.sourceip,
--     match.session_end_reason;

--dump center