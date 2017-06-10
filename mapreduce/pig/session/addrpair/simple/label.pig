%default CLUSTER_NUMBER 5

S = LOAD 'tmp-join' USING PigStorage(',') AS (dip:chararray, sip:chararray, sid:long, bytes:long);

-- dump S

labeled = FOREACH S GENERATE
	       (int)FLOOR(RANDOM() * $CLUSTER_NUMBER) AS label,
	       dip,
	       sip,
	       sid,
	       bytes;

-- dump labeled;

LG = GROUP labeled BY label;

LGF = FOREACH LG GENERATE
      	   group as label,
	   AVG(labeled.sid),
	   AVG(labeled.bytes);

dump LGF;

