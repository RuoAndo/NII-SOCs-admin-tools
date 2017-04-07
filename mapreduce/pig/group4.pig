REGISTER piggybank.jar;
DEFINE POW org.apache.pig.piggybank.evaluation.math.POW();

-- %default SRCS 'session-0305-1100.csv'
session = LOAD '$SRCS' USING PigStorage(',') AS (session_id:int,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray, src_country_code:chararray, destination_ip:chararray, dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:int,bytes_sent:int,bytes_received:int,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:int,dest_university_name:chararray);

session_group = GROUP session BY src_university_id;

center = FOREACH session_group GENERATE
     group as label,
     AVG(session.bytes) as avrbytes,
     -- AVG(session.source_ip) as sourceip,
     -- AVG(session.destination_ip) as destip
     session.source_ip as sourceip,
     session.destination_ip as destip
;

dump center
--STORE alert_join INTO 'join2.dump';

-- session_cross = CROSS session, center;

-- diff_calc = FOREACH session_cross GENERATE
--	  center::label AS label,
--	  session::session_id,
--	  POW(session::bytes - center::avrbytes)
--	  POW(session::destination_ip - center::avrdstip)
--	  POW(session::source_ip - center::avrsrcip)
-- ;

-- dump diff_calc
-- STORE diff_calc INTO 'group.dump';

