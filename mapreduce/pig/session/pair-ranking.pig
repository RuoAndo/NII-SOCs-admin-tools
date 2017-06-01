sessions = LOAD '$SRCS' USING PigStorage(',') AS (session_id:int,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:int,bytes_sent:int,bytes_received:int,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:int,dest_university_name:chararray);

-- sessions_group = GROUP sessions BY session_id;                                     

session_filtered = FOREACH sessions GENERATE
	session_id as session_sessionid,
	source_ip as session_sourceip;

session_filtered_group = GROUP session_filtered by session_sourceip;
--dump session_filtered_group;

session_group = FOREACH session_filtered_group GENERATE
	      COUNT(session_filtered.session_sessionid) as sidcount,
	      FLATTEN(session_filtered.session_sourceip);
--dump session_group;

addrpair = FOREACH sessions GENERATE
	session_id as pair_sessionid,
	destination_ip as pair_destip,
	source_ip as pair_sourceip;

addrpair_distinct = DISTINCT addrpair;
-- dump addrpair_distinct;

addr_join = JOIN session_group by session_sourceip,
	    	 addrpair_distinct by pair_sourceip;
--dump addr_join;

ranking = ORDER addr_join BY $0 DESC;
ranking_distinct = DISTINCT ranking;
dump ranking_distinct;

--addr_join = JOIN session_filtered by session_sourceip,
--	    	 addrpair_distinct by pair_sourceip;
--dump addr_join;

--addr_join_group = GROUP addr_join BY pair_sourceip;
--dump addr_join_group;

--addrpair_group_count = FOREACH addr_join_group GENERATE
--      		COUNT(addr_join.sessionid) as sidcount,
--		addr_join.pair_destip as destip,
--		addr_join.pair_sourceip as sourceip;
--dump addrpair_group_count;

--ranking = ORDER addrpair_group_count BY sidcount DESC;
--dump ranking;

--dump addrpair;
--

--addrpair_group_count = FOREACH addrpair_group GENERATE
--      		COUNT(addrpair.sourceip),
--		addrpair.sessionid,
--		addrpair.destip;

--dump addrpair_group_count;

--addrpair_distinct = DISTINCT addrpair;

--addr_join = JOIN addrpair by sourceip,
--	    	 addrpair_distinct by sourceip;

--addr_group = GROUP addr_join ALL;

--addr_join_count = FOREACH addr_group GENERATE
--		COUNT(addrpair.sourceip),
--		addrpair_distinct.sourceip;

--dump addr_join_count;

--dump addr_join;

-- dump addrpair_distinct
-- STORE addrpair_distinct INTO '$SRCS.dump';

