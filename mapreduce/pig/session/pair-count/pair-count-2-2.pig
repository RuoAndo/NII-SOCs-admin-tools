-- STEP 2:tmp-sg
session_filtered_2 = LOAD 'tmp-sf' USING PigStorage(',') AS (sessionid:long, sourceip:chararray);
session_filtered_group = GROUP session_filtered_2 by sourceip;
session_group = FOREACH session_filtered_group GENERATE
	      COUNT(session_filtered_2.sessionid) as sidcount,
	      FLATTEN(session_filtered_2.sourceip);
session_group_ordered = ORDER session_group BY sidcount DESC;

-- session_group_limit = LIMIT session_group_ordered 100;
session_group_limit = session_group_ordered;

STORE session_group_limit INTO 'tmp-sg' USING PigStorage(',');