REGISTER piggybank.jar;

records = LOAD '$SRCS' USING PigStorage(',') AS (session_id:int,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:int,bytes_sent:int,bytes_received:int,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:int,dest_university_name:chararray);

-- records_group = GROUP records BY source_ip;
-- dump records_group

avg = FOREACH records GENERATE
      bytes_sent -  bytes_received as diff,
      -- ABS(bytes_sent -  bytes_received) as abs,
      bytes_sent as sent,
      bytes_received as received,
      capture_time as time,
      source_ip as sip,
      dest_university_name as name;

-- dump avg;

avg2 = FILTER avg BY diff < 0;
avg2_sorted = ORDER avg2 BY diff;
dump avg2_sorted;
