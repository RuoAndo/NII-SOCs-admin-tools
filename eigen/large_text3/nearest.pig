REGISTER piggybank.jar;
DEFINE POW org.apache.pig.piggybank.evaluation.math.POW();

S = LOAD '$ALL2' USING PigStorage(',') AS (label:int, sip:chararray, dip:chararray, bytes_sent:double, bytes_received:double, sidcount:double);

C = LOAD '$CENTROID' USING PigStorage(',') AS (cbytes_sent:double, cbytes_received:double, csidcount:double);

dump C;

D = FOREACH S GENERATE
    	    sip,
	    dip,
    	    bytes_sent,
    	    bytes_received,
    	    sidcount,
	    SQRT(POW((bytes_sent - C.cbytes_sent),2) + POW((bytes_received - C.cbytes_received),2) + POW((sidcount - C.csidcount),2)) as norm;

SS = ORDER D BY norm ASC;                                                                                  
SSS = LIMIT SS 10;                        
 
dump SSS;
                                      
--dump AVG;
--STORE AVG INTO '$SRCS-avg' USING PigStorage(',');