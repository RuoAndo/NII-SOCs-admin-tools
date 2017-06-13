S = LOAD 'tmp-sid' USING PigStorage(',') AS (destip:chararray, sourceip:chararray, sid:long);
A = LOAD 'tmp-avg' USING PigStorage(',') AS (destip:chararray, sourceip:chararray, avg:long);

-- J = JOIN S by sourceip, A by sourceip;
J = join S by (destip, sourceip) LEFT OUTER, A by (destip, sourceip);

-- DUMP J;

JJ = FOREACH J GENERATE
      	     $0,
	     $1,
	     $2,
	     $5;

J_D = DISTINCT JJ;
dump J_D
STORE J_D INTO 'tmp-join' USING PigStorage(',');
