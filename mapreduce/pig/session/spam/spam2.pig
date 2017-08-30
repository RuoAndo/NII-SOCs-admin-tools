A = LOAD 'spam-PF' USING PigStorage(',') AS (dip:chararray, sip:chararray, dport:int, sport:int, bytes_sent:double, bytes_received:double, sidcount:long); 
--dump A;

gl = GROUP A by (dip, sip);

AVG = FOREACH gl GENERATE
      FLATTEN(A.dip),
      FLATTEN(A.sip),
      -- FLATTEN(A.sport),
      AVG(A.bytes_sent) as avgbytes_sent,
      AVG(A.bytes_received) as avgbytes_received,
      COUNT(A.sidcount) as avgsidcount;

AVG_D = DISTINCT AVG;

dump AVG_D;