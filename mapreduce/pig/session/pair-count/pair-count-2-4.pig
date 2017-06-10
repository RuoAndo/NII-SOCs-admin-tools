-- STEP 4: tmp-ad
session_group_2 = LOAD 'tmp-sg' USING PigStorage(',') AS (sidcount:long, sourceip:chararray);
addrpair_distinct_2 = LOAD 'tmp-ad' USING PigStorage(',') AS (sessionid:long, destinationip:chararray, sourceip:chararray);
addr_join = JOIN session_group_2 by sourceip,
	    	 addrpair_distinct_2 by sourceip;
STORE addr_join INTO 'tmp-aj' USING PigStorage(',');