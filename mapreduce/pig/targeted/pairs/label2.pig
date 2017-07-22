REGISTER piggybank.jar;
DEFINE POW org.apache.pig.piggybank.evaluation.math.POW();
DEFINE SQRT org.apache.pig.piggybank.evaluation.math.SQRT();

%default CLUSTER_NUMBER 5

S = LOAD '$SRCS' USING PigStorage(',') AS (dip:chararray, sip:chararray, alert1:double, alert2:double, alert3:double);
--dump 

SPLIT S INTO
      S_error  IF dip is null,
      labeled IF dip is not null;

labeled = FOREACH S GENERATE
	       (int)FLOOR(RANDOM() * $CLUSTER_NUMBER) AS label,
	       dip,
	       sip,
	       (double)(alert1 * 100000) as alert1,
	       (double)(alert2 * 100000) as alert2,
	       (double)(alert3 * 100000) as alert3;

-- dump labeled

gl = GROUP labeled by label;

AVG = FOREACH gl GENERATE
      group as label,
      AVG(labeled.alert1) as avg_alert1,
      AVG(labeled.alert2) as avg_alert2,
      AVG(labeled.alert3) as avg_alert3;

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