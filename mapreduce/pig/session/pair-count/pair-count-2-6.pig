-- STEP 6: tmp-rfd
ranking_2 = LOAD 'tmp-rk' USING PigStorage(',') AS (sidcount:long, sourceip:chararray, pair_sessionid:long, pair_destip:chararray, pair_sourceip:chararray);
ranking_filtered = FOREACH ranking_2 GENERATE
		   	   sidcount,
			   pair_destip,
			   pair_sourceip;

ranking_filtered_distinct = DISTINCT ranking_filtered;
-- dump ranking_filtered_distinct;
STORE ranking_filtered_distinct INTO 'tmp-rfd' USING PigStorage(',');