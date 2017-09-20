REGISTER piggybank.jar;
DEFINE POW org.apache.pig.piggybank.evaluation.math.POW();

S = LOAD 'dump_fanout1_$SRCS' USING PigStorage(',') AS (session_id:long, capture_time:chararray, dip:chararray, sip:chararray, sport:int, dport:int, bsent:long, brecv:long);

session_group = GROUP S BY sip; 

avg = FOREACH session_group GENERATE
      group as avg_label,
      S.session_id as sid,
      S.dip as dip,
      S.sip as sip,
      S.sport as sport,
      S.dport as dport,
      S.bsent as bsent,
      S.brecv as brecv;

fanout = FOREACH avg GENERATE
	avg_label,
	COUNT(dip),
	AVG(bsent),
	AVG(brecv);
	
--dump fanout;
STORE fanout INTO 'dump_fanout2_$SRCS' USING PigStorage(','); 