REGISTER piggybank.jar;
DEFINE POW org.apache.pig.piggybank.evaluation.math.POW();
DEFINE SQRT org.apache.pig.piggybank.evaluation.math.SQRT();

%default CLUSTER_NUMBER 5

S = LOAD '$SRCS' USING PigStorage(',') AS (label:int, dip:chararray, sip:chararray, bytes_sent:long, bytes_received:long, sid:long);
--dump S

SPLIT S INTO
      S_error  IF dip is null,
      labeled IF dip is not null;

labeled = FOREACH S GENERATE
	       (int)FLOOR(RANDOM() * $CLUSTER_NUMBER) AS label,
	       dip,
	       sip,
	       bytes_sent,
	       bytes_received,
	       sid;

-- dump labeled

gl = GROUP labeled by label;

AVG = FOREACH gl GENERATE
      group as label,
      AVG(labeled.bytes_sent) as avgbytes_sent,
      AVG(labeled.bytes_received) as avgbytes_received,
      AVG(labeled.sid) as avgsid;

STORE AVG INTO 'tmp-avg' USING PigStorage(',');
-- dump AVG

CLS0 = FILTER labeled BY label == 0;
STORE CLS0 INTO 'tmp-cls-0' USING PigStorage(',');

CLS1 = FILTER labeled BY label == 1;
STORE CLS1 INTO 'tmp-cls-1' USING PigStorage(',');

CLS2 = FILTER labeled BY label == 2;
STORE CLS2 INTO 'tmp-cls-2' USING PigStorage(',');

CLS3 = FILTER labeled BY label == 3;
STORE CLS3 INTO 'tmp-cls-3' USING PigStorage(',');

CLS4 = FILTER labeled BY label == 4;
STORE CLS4 INTO 'tmp-cls-4' USING PigStorage(',');