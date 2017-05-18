REGISTER piggybank.jar;
DEFINE POW org.apache.pig.piggybank.evaluation.math.POW();

session = LOAD '$SRCS' USING PigStorage(',') AS (session_id:long,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:double,bytes_sent:double,bytes_received:double,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:int,dest_university_name:chararray);

abs = FOREACH session GENERATE
      session_id,
      capture_time,
      ABS(bytes_sent -  bytes_received) as abs,                             
      bytes_sent -  bytes_received as diff,
      -- src_university_id,
      -- src_university_name,
      destination_ip,
      source_ip,
      source_port,
      destination_port,
      bytes_sent,
      bytes_received;
  
-- dump abs;

session_group = GROUP abs BY source_ip; 

avg = FOREACH session_group GENERATE
      group as avg_label,
      abs.session_id as avg_session_id,
      abs.capture_time as avg_capture_time,
      abs.source_ip as avg_source_ip,
      abs.destination_ip as avg_destination_ip,
      abs.source_port as avg_source_port,
      abs.destination_port as avg_destination_port,
      abs.bytes_sent,
      abs.bytes_received,
      AVG(abs.bytes_sent) as avg_sent,
      AVG(abs.bytes_received) as avg_received,
      AVG(abs.abs) as avg_abs;

-- dump avg;

diff = FOREACH avg GENERATE
     avg_label,
     avg_session_id,
     avg_capture_time,
     avg_abs;

diff_sorted = ORDER diff BY avg_abs DESC;
limit_diff_sorted = LIMIT diff_sorted 10;
dump limit_diff_sorted;

STORE limit_fanout_sorted INTO 'ranking.$LOGDATE.dump';  

/*
diff_group = GROUP diff all;

std = FOREACH diff_group GENERATE
     AVG(diff.avg_abs)/COUNT(diff.avg_label);

dump std;

session_cross = cross diff, std;
dump session_cross
*/

/*
diff = FOREACH session_cross GENERATE
       	    avg_label,
	    avg_session_id,
	    avg_capture_time,
	    avg_source_ip,
	    avg_destination_ip,
	    avg_source_port,
	    avg_destination_port,
	    avg_sent,
	    avg_received,
	    SQRT(POW((abs - avg_abs),2)/avg_cnt_abs) as std;
	    
dump diff;
diff_filtered = FILTER diff BY ((std != -1) AND (std != 1));

*/