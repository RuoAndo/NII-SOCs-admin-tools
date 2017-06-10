-- STEP4: COUNT

H_2 = LOAD 'tmp-H' USING PigStorage(',') AS (d:chararray, s:chararray, destip:chararray, sourceip:chararray, sid:long);

I = GROUP H_2 BY (d, s);

F = FOREACH I GENERATE
    	    FLATTEN(H_2.d),
	    FLATTEN(H_2.s),
	    COUNT(H_2.sid) as count;
F_D = DISTINCT F;

STORE F_D INTO 'tmp-F_D' USING PigStorage(',');