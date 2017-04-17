%default SRC 'targeted_alarm.csv'
records = LOAD '$SRC' USING PigStorage(',') AS (targeted_alarm_id:int, capture_time:chararray, src_university_id:int, dest_university_id:int, mail_send_status:chararray ,subtype:chararray, generated_time:chararray, source_ip:chararray, src_country_code:chararray, destination_ip:chararray, dest_country_code:chararray, rule_name:chararray, source_user:chararray, destination_user:chararray, application:chararray, virtual_system:chararray, source_zone:chararray, destination_zone:chararray, log_forwarding_profile:chararray, repeat_cnt:int,source_port:int,destination_port:int, flags:chararray, protocol:chararray, action:chararray, alarm_name:chararray, threat_id:int, category:chararray, severity:chararray, direction:chararray, source_location:chararray, destination_location:chararray, content_type:chararray, file_digest:chararray, user_agent:chararray, file_type:chararray, x_forwarded_for:chararray, src_university_name:chararray, dest_university_name:chararray);


records_group = GROUP records BY alarm_name;                                                            

counter = FOREACH records_group GENERATE                                                         
	group as label,
	records.destination_ip as destip,
	records.dest_university_name as destuniv,
	COUNT(records.targeted_alarm_id) as idcount;   

ordered_counter = ORDER counter BY idcount DESC;

filtered_counter = FILTER ordered_counter BY idcount <= 2;
dump filtered_counter
STORE filtered_counter INTO '$SRC.dump';


