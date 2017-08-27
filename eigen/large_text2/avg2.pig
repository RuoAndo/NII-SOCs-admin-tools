REGISTER piggybank.jar;
DEFINE POW org.apache.pig.piggybank.evaluation.math.POW();
DEFINE SQRT org.apache.pig.piggybank.evaluation.math.SQRT();

S = LOAD '$SRCS' USING PigStorage(',') AS (label:int, sip:chararray, dip:chararray, bytes_sent:double, bytes_received:double, sidcount:double);

gl = GROUP S by label;

AVG = FOREACH gl GENERATE
      COUNT(S.sidcount) as countavg,
      group as label,
      AVG(S.bytes_sent) as avgbytes_sent,
      AVG(S.bytes_received) as avgbytes_received,
      AVG(S.sidcount) as avgsidcount;

dump AVG;