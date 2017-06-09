sessions = LOAD '$SRCS' USING PigStorage(',') AS (session_id:long,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:int,bytes_sent:int,bytes_received:int,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:int,dest_university_name:chararray);

session_filtered = FOREACH sessions GENERATE
	session_id as session_sessionid,
	source_ip as session_sourceip;
STORE session_filtered INTO 'tmp-sf' USING PigStorage(',');

session_filtered_2 = LOAD 'tmp-sf' USING PigStorage(',') AS (sessionid:long, sourceip:chararray);
session_filtered_group = GROUP session_filtered_2 by sourceip;
session_group = FOREACH session_filtered_group GENERATE
	      COUNT(session_filtered_2.sessionid),
	      FLATTEN(session_filtered_2.sourceip);
STORE session_group INTO 'tmp-sg' USING PigStorage(',');

addrpair = FOREACH sessions GENERATE
	session_id as pair_sessionid,
	destination_ip as pair_destip,
	source_ip as pair_sourceip;

addrpair_distinct = DISTINCT addrpair;
STORE addrpair_distinct INTO 'tmp-ad' USING PigStorage(',');

session_group_2 = LOAD 'tmp-sg' USING PigStorage(',') AS (sidcount:long, sourceip:chararray);
--dump session_group_2;
addrpair_distinct_2 = LOAD 'tmp-ad' USING PigStorage(',') AS (sessionid:long, destinationip:chararray, sourceip:chararray);
addr_join = JOIN session_group_2 by sourceip,
	    	 addrpair_distinct_2 by sourceip;
STORE addr_join INTO 'tmp-aj' USING PigStorage(',');

addr_join_2 = LOAD 'tmp-aj' USING PigStorage(',') AS (sidcount:long, sourceip:chararray, pair_sessionid:long, pair_destip:chararray, pair_sourceip:chararray);
ranking = ORDER addr_join_2 BY sidcount ASC;
ranking_filtered = FOREACH ranking GENERATE
		   	   sidcount,
			   pair_destip,
			   pair_sourceip;

ranking_filtered_distinct = DISTINCT ranking_filtered;
dump ranking_filtered_distinct;

