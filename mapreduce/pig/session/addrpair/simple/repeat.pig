REGISTER piggybank.jar;
DEFINE POW org.apache.pig.piggybank.evaluation.math.POW();
DEFINE SQRT org.apache.pig.piggybank.evaluation.math.SQRT();

%default CLUSTER_NUMBER 5

-- 3,103.243.221.87,133.35.64.23,2,6968,1077.0717635786887
S = LOAD 'tmp-label' USING PigStorage(',') AS (label:int, dip:chararray, sip:chararray, sid:long, bytes:long, norm:long);

LG = GROUP S BY label;

LGF = FOREACH LG GENERATE
      	   group as label,
	   AVG(S.sid) as avgsid,
	   AVG(S.bytes) as avgbytes;

-- dump LGF;

CR = CROSS LGF, S;
--dump CR;

-- (0,1.2017543859649122,9015.350877192983,3,101.102.255.91,160.29.170.2,1,432,5458)

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
		      FLATTEN(result01.label) as label,
		      FLATTEN(result01.dip) as dip,
		      FLATTEN(result01.sip) as sip,
		      FLATTEN(result01.sid) as sid,
		      FLATTEN(result01.bytes) as bytes,
	     	      FLATTEN(result01.norm) as norm;
             };
-- dump CR4;

STORE CR4 INTO 'tmp-label-2' USING PigStorage(',');

R = join S by (dip, sip) LEFT OUTER, CR4 by (dip, sip);
-- dump R;

R = FILTER R BY S::label != CR4::label;

RG = GROUP R ALL;
RC = FOREACH RG GENERATE
     	     FLATTEN(COUNT(R));

dump RC;
STORE RC INTO 'tmp-diff' USING PigStorage(',');