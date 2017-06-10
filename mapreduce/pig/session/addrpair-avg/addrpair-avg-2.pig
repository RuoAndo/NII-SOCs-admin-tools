--STEP2: tmp-addrpair-avg
addrpair_distinct_2 = LOAD 'tmp-addrpair' USING PigStorage(',') AS (destip:chararray, sourceip:chararray, bytes:int);
addrpair_group = GROUP addrpair_distinct_2 BY (destip, sourceip);
addrpair_avg = FOREACH addrpair_group GENERATE
	       	       group as label,
		       AVG(addrpair_distinct_2.bytes);
STORE addrpair_avg INTO 'tmp-addrpair-avg' USING PigStorage(',');