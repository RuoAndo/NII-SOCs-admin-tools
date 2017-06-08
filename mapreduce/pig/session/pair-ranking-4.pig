session1 = LOAD 'tmp-osg' USING PigStorage(',') AS (sidcount:long, source_ip:chararray);

-- dump session1

--COUNT(session_filtered.session_sessionid) as sidcount,
--FLATTEN(session_filtered.session_sourceip);

session2 = LOAD 'tmp-ad' USING PigStorage(',') AS (destination_ip:chararray, source_ip:chararray);

-- dump session2;

session_join = JOIN session1 by source_ip, session2 by source_ip;
--dump session_join;

final = ORDER session_join by sidcount DESC;
--dump final;

final_distinct = DISTINCT final;
final_ordered = ORDER final_distinct by sidcount DESC;
dump final_ordered;

--session_id as pair_sessionid,
--destination_ip as pair_destip,
--source_ip as pair_sourceip;


