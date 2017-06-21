REGISTER date.jar;

--STEP2

PF_2 = LOAD 'tuple-PF' USING PigStorage(',') AS (sid:long, ct:chararray,dip:chararray, sip:chararray, bytes:long);

Q = FOREACH PF_2 GENERATE
      sid as sid,
      date.DATE(ct) as ct,
      dip as dip,
      sip as sip,
      bytes as bytes;

--dump Q;

STORE Q INTO 'tuple-Q' USING PigStorage(',');