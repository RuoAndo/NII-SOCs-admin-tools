-- STEP 5: tmp-rk
addr_join_2 = LOAD 'tmp-aj' USING PigStorage(',') AS (sidcount:long, sourceip:chararray, pair_sessionid:long, pair_destip:chararray, pair_sourceip:chararray);
addr_join_3 = DISTINCT addr_join_2;

ranking = ORDER addr_join_3 BY $0 DESC;
--dump ranking;
STORE ranking INTO 'tmp-rk' USING PigStorage(',');