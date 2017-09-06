S = LOAD '$SRCS' AS (session_id:long,capture_time:chararray,sip:chararray,sport:int,suid:int,dip:chararray,dport:int,duid:int,bytes_sent:int, bytes_received:long);

GL = GROUP S by (dip, sip);

GLF = FOREACH GL GENERATE
      FLATTEN(S.sip),
      FLATTEN(S.suid),
      -- FLATTEN(S.sport),
      FLATTEN(S.dip),
      FLATTEN(S.duid),
      -- FLATTEN(S.dport),
      AVG(S.bytes_sent),
      AVG(S.bytes_received),
      COUNT(S.session_id);

-- dump GLF;

GLFD = DISTINCT GLF;
dump GLFD;
