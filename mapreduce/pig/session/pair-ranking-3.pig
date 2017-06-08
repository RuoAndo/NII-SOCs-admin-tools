sessions = LOAD '$SRCS' USING PigStorage(',') AS (session_id:long,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:int,bytes_sent:int,bytes_received:int,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:int,dest_university_name:chararray);

addrpair = FOREACH sessions GENERATE
	destination_ip as pair_destip,
	source_ip as pair_sourceip;

STORE addrpair INTO 'tmp-ap' USING PigStorage(',');
addrpair2 = LOAD 'tmp-ap' USING PigStorage(',') AS (destination_ip:chararray, source_ip:chararray);

addrpair_distinct = DISTINCT addrpair2;
--addrpair_limit = LIMIT addrpair_distinct 100;
--dump addrpair_distinct;
STORE addrpair_distinct INTO 'tmp-ad' USING PigStorage(',');
--STORE addrpair_distinct INTO 'tmp-ad' USING PigStorage(',');
