addrpair_distinct_2 = LOAD 'tmp-pair' USING PigStorage(',') AS (destip:chararray, sourceip:chararray, sid:long);
addrpair_group = GROUP addrpair_distinct_2 BY (destip, sourceip);
addrpair_sid = FOREACH addrpair_group GENERATE
	       	       group as label,
		       COUNT(addrpair_distinct_2.sid);

-- dump addrpair_avg;
STORE addrpair_sid INTO 'tmp-sid' USING PigStorage(',');