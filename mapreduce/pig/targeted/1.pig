alarm = LOAD '$SRCT' USING PigStorage(',') AS (targeted_alarm_id:int, capture_time:chararray, src_university_id:int, dest_university_id:int, mail_send_statusl:chararray, application_protocol:chararray, classification:chararray, client:chararray, dest_ip:chararray, dest_country_code:chararray, dest_port_or_icmp_code:chararray, intrusion_policy:chararray, alarm_name:chararray, network_analysis_policy:chararray, priority:chararray, protocol:chararray, generator_id:chararray, snort_id:chararray, revision:chararray, src_ip:chararray, src_countr_code:chararray, src_port_or_icmp_code:chararray, src_univeristy_name:chararray, dest_university_name:chararray);

-- dump alarm

F = FOREACH alarm GENERATE
    	    targeted_alarm_id as tid,
    	    dest_ip as dip,
	    src_ip as sip;

FF = FILTER F BY (sip MATCHES '.\\d+\\.\\d+\\.\\d+\\.\\d+') OR (dip MATCHES '.\\d+\\.\\d+\\.\\d+\\.\\d+');
    
H = GROUP FF BY (dip, sip);

dump H;
-- dump FF;

C = FOREACH H GENERATE
    	    COUNT(FF.tid) as tidcount,
	    FF.dip,
	    FF.sip;

dump C;
	    

