S = LOAD '$SRCS' USING PigStorage(',') AS (session_id:long,capture_time:chararray,sip:chararray,sport:int, dip:chararray,dportint, bytes_sent:long, bytes_received:long);

dump S;
