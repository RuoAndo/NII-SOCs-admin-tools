--STEP3
Q_2 = LOAD 'tuple-Q' USING PigStorage(',') AS (sid:long, ct:long ,dip:chararray, sip:chararray, bytes:long);

QG = GROUP Q_2 by sip;
QGF = FOREACH QG GENERATE
      	      group as label,
	      FLATTEN(Q_2.sid),
	      FLATTEN(Q_2.ct),
	      FLATTEN(Q_2.dip);	      

--dump QGF;
STORE QGF INTO '$OUTPUTDIR' USING PigStorage(',');