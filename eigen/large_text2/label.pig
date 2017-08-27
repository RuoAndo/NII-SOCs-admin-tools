REGISTER piggybank.jar;
DEFINE POW org.apache.pig.piggybank.evaluation.math.POW();
DEFINE SQRT org.apache.pig.piggybank.evaluation.math.SQRT();

%default CLUSTER_NUMBER 10

S = LOAD '$SRCS' USING PigStorage(',') AS (sip:chararray, dip:chararray, bytes_sent:double, bytes_received: double, sidcount:double);

-- dump S

labeled = FOREACH S GENERATE
	       (int)FLOOR(RANDOM() * $CLUSTER_NUMBER) AS label,
	       sip,
	       dip,
	       bytes_sent,
	       bytes_received,
	       sidcount;

dump labeled;

-- gl = GROUP labeled by label;

-- AVG = FOREACH gl GENERATE
--      group as label,
--      AVG(labeled.bytes_sent) as avgbytes_sent,
--      AVG(labeled.bytes_received) as avgbytes_received,
--      AVG(labeled.sidcount) as avgsidcount;

-- dump AVG;