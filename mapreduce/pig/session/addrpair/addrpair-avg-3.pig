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