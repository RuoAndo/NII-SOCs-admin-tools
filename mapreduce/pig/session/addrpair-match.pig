session = LOAD '$SRCS' USING PigStorage(',') AS (session_id:int,capture_time:chararray,src_and_dest_ip_class:chararray,src_university_id:int,dest_university_id:int,subtype:chararray,generated_time:chararray,source_ip:chararray,src_country_code:chararray,destination_ip:chararray,dest_country_code:chararray,rule_name:chararray,source_user:chararray,destination_user:chararray,application:chararray,virtual_system:chararray,source_zone:chararray,destination_zone:chararray,log_forwarding_profile:chararray,repeat_cnt:int,source_port:int,destination_port:int,flags:chararray,protocol:chararray,action:chararray,bytes:int,bytes_sent:int,bytes_received:int,packets:int,start_time:chararray,elapsed_time:chararray,category:chararray,source_location:chararray,destination_location:chararray,packets_sent:int,packets_received:int,session_end_reason:chararray,action_source:chararray,src_university_name:chararray,dest_university_name:chararray);

P = FOREACH session GENERATE                                    
	   	   destination_ip as dip,
		   source_ip as sip,
		   bytes as bytes;

A = LOAD 'tmp-addrpair' USING PigStorage(',') AS (dip:chararray, sip:chararray);

J = join P by (dip, sip) LEFT OUTER, A by (dip, sip); 
dump J;

I = FOREACH J GENERATE
    $0 as dip,    
    $1 as sip,
    $2 as bytes;

H = GROUP I BY ($0, $1);
dump H;

K = FOREACH H GENERATE    	   
    FLATTEN(I.dip),
    FLATTEN(I.sip),
    AVG(I.bytes);

dump K;