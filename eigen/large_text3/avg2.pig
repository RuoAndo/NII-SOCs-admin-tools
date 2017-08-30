S = LOAD '$SRCS' USING PigStorage(',') AS (label:int, sip:chararray, dip:chararray, bytes_sent:double, bytes_received:double, sidcount:double);

gl = GROUP S by label;

AVG = FOREACH gl GENERATE
      group as label,
      AVG(S.bytes_sent),
      AVG(S.bytes_received),
      AVG(S.sidcount);

dump AVG;
STORE AVG INTO '$SRCS-avg' USING PigStorage(',');