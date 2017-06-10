REGISTER piggybank.jar;
DEFINE POW org.apache.pig.piggybank.evaluation.math.POW();
DEFINE SQRT org.apache.pig.piggybank.evaluation.math.SQRT();

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
	   AVG(labeled.sid) as avgsid,
	   AVG(labeled.bytes) as avgbytes;

-- (4,1.0472693421597021,1671.9184940008274,3,158.215.218.229,1.34.40.246,1,60)

CR = CROSS LGF, labeled;

CR2 = FOREACH CR GENERATE
              $0 as label,
       	      $1,
	      $2,
	      $3,
	      $4 as dip,
	      $5 as sip,
	      $6 as sid,
	      $7 as bytes,
      	      SQRT(POW($1-$6,2)+POW($2-$7,2)) as norm;

CR3 = GROUP CR2 BY (dip, sip);
-- dump CR3

CR4 = FOREACH CR3 {
      	     result00 = ORDER CR2 BY norm ASC;
    	     result01 = LIMIT result00 1;
	     GENERATE
		      result01.label,
		      result01.dip,
		      result01.sip,
		      result01.sid,
		      result01.bytes,
	     	      result01.norm;
             };
dump CR4;

