session = LOAD '$SRCS' USING PigStorage(',') AS (label:int,sip:chararray,dip:chararray,bytes_avg:long, sidcount:int);

SG = GROUP session BY label;

AVG = FOREACH SG GENERATE
      group as label,
      AVG(session.bytes_avg) as avg_bytes,
      AVG(session.sidcount) as avg_sidcount;

dump AVG;

