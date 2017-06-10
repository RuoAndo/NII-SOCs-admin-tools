S = LOAD 'tmp-s' USING PigStorage(',') AS (sid:long, ct:long, dip:long, sip:long, bytes:long);

S_G = GROUP S ALL;

bytes_avg = FOREACH S_G GENERATE
    	    AVG(S.bytes);

bytes = FOREACH S GENERATE 
      	      FLATTEN(bytes);

bytes_crossed = CROSS bytes_avg, bytes;

bytes_diff = FOREACH bytes_crossed GENERATE
	    $0-$1;

STORE bytes_diff INTO 'tmp-bytes' USING PigStorage(',');