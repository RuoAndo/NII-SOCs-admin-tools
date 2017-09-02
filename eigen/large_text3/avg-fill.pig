REGISTER piggybank.jar;
DEFINE POW org.apache.pig.piggybank.evaluation.math.POW();

S = LOAD '$ALL2' USING PigStorage(',') AS (sip:chararray, dip:chararray, bytes_sent:double, bytes_received:double, sidcount:double);

C = LOAD '$CENTROID' USING PigStorage(',') AS (cbytes_sent:double, cbytes_received:double, csidcount:double);

D = FOREACH S GENERATE
    dip,
    SQRT(POW((bytes_sent - cbytes_sent),2));

dump D;

--dump AVG;
--STORE AVG INTO '$SRCS-avg' USING PigStorage(',');