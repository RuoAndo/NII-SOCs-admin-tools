session = LOAD '$SRCS' USING PigStorage(',') AS (session:int,sip:chararray,dip:chararray,sidcount:int);
dump session;
