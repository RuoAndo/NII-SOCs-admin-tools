S = LOAD 'tmp-sid' USING PigStorage(',') AS (destip:chararray, sourceip:chararray, sid:long);
A = LOAD 'tmp-sid' USING PigStorage(',') AS (destip:chararray, sourceip:chararray, avg:long);

J = JOIN S by sourceip, A by sourceip;
DUMP J;

