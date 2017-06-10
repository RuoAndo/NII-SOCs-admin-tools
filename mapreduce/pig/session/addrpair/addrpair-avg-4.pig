-- STEP4: COUNT

H_2 = LOAD 'tmp-H' USING PigStorage(',') AS (d:chararray, s:chararray, destip:chararray, sourceip:chararray, bytes:long);

I = GROUP H_2 BY (d, s);

F = FOREACH I GENERATE
    	    FLATTEN(H_2.d),
	    FLATTEN(H_2.s),
	    AVG(H_2.bytes) as avgbytes;
F_D = DISTINCT F;

STORE F_D INTO 'tmp-F_D' USING PigStorage(',');