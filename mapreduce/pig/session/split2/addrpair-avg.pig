-- STEP 2
-- 8.8.4.4,202.245.103.10,1334,8.8.4.4,202.245.103.10
J_2 = LOAD 'addrpair-join' USING PigStorage(',') AS (dip:chararray, sip:chararray, sid:long, bytes_sent:long, bytes_received:long, dip2:chararray, sip2:chararray);

I = FOREACH J_2 GENERATE
    $0 as dip,    
    $1 as sip,
    $3 as bytes;

H = GROUP I BY (dip, sip);
-- dump H;

K = FOREACH H GENERATE    	   
    FLATTEN(I.dip),
    FLATTEN(I.sip),
    AVG(I.bytes_sent);
    AVG(I.bytes_received);

--dump K;

K_D = DISTINCT K;
STORE K_D INTO '$OUTPUTDIR' USING PigStorage(',');