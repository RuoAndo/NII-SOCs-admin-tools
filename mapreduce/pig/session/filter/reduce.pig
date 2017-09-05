S = LOAD '$SRCS' USING PigStorage(',') AS (session_id:long,capture_time:chararray,sip:chararray,sport:int,dip:chararray, dport:int, bytes_sent:int, bytes_received:long);

GL = GROUP S by (dip, sip);

GLF = FOREACH GL GENERATE
      FLATTEN(S.dip),
      -- FLATTEN(S.dport),
      FLATTEN(S.sip),
      -- FLATTEN(S.sport),
      AVG(S.bytes_sent),
      AVG(S.bytes_received),
      COUNT(S.session_id);

-- dump GLF;

GLFD = DISTINCT GLF;
dump GLFD;
