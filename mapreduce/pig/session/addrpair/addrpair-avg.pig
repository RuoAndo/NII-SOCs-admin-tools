--STEP1: DISTINCT
session = LOAD '$SRCS' USING PigStorage(',') AS (session_id:long,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:int,bytes_sent:int,bytes_received:int,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:chararray,dest_university_name:chararray);

Pair = FOREACH session GENERATE                                    
	   	   destination_ip as destip,
		   source_ip as sourceip;
		   
P_D = DISTINCT Pair;
-- dump addrpair_distinct
STORE P_D INTO 'tmp-addrpair' USING PigStorage(',');

-- STEP2: tmp-sf : FILTER
S_F = FOREACH session GENERATE
		 	   destination_ip as destip,
		   	   source_ip as sourceip,
		   	   bytes as bytes;

STORE S_F INTO 'tmp-sf' USING PigStorage(',');

-- STEP3: JOIN 

addrpair_distinct = LOAD 'tmp-addrpair' USING PigStorage(',') AS (destip:chararray, sourceip:chararray);

session_filtered = LOAD 'tmp-sf' USING PigStorage(',') AS (destip:chararray, sourceip:chararray, bytes:long);

J = JOIN addrpair_distinct by sourceip, session_filtered by sourceip;
-- dump J;

H = FOREACH J GENERATE
    	    $0 as d,
	    $1 as s,
	    $2 as destip,
	    $3 as sourceip,
	    $4 as bytes;

STORE H INTO 'tmp-H' USING PigStorage(',');

-- STEP4: COUNT

H_2 = LOAD 'tmp-H' USING PigStorage(',') AS (d:chararray, s:chararray, destip:chararray, sourceip:chararray, bytes:long);

I = GROUP H_2 BY (d, s);

F = FOREACH I GENERATE
    	    FLATTEN(H_2.d),
	    FLATTEN(H_2.s),
	    AVG(H_2.bytes) as avgbytes;
F_D = DISTINCT F;

STORE F_D INTO 'tmp-F_D' USING PigStorage(',');

-- STEP5: ORDER

F_D_2 = LOAD 'tmp-F_D' USING PigStorage(',') AS (d:chararray, s:chararray, avgbytes:long);

F_D_O = ORDER F_D_2 BY avgbytes DESC;
STORE F_D_O INTO 'tmp-avg-bytes' USING PigStorage(',');
