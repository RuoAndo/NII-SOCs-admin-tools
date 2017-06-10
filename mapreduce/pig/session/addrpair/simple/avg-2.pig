-- STEP2:

addrpair_distinct_2 = LOAD 'tmp-pair' USING PigStorage(',') AS (destip:chararray, sourceip:chararray, bytes:int);
addrpair_group = GROUP addrpair_distinct_2 BY (destip, sourceip);
addrpair_avg = FOREACH addrpair_group GENERATE
	       	       group as label,
		       AVG(addrpair_distinct_2.bytes) as avg;

A = FOREACH addrpair_avg GENERATE
    	    FLATTEN(label),
	    avg;
--dump A;

-- dump addrpair_avg;
STORE A INTO 'tmp-avg' USING PigStorage(',');