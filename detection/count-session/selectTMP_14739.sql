select src_university_id,dest_university_id,count(capture_time) from session_info_20171017 
where capture_time >= '2017/10/17 00:13:10' and capture_time < '2017/10/17 00:18:10' 
GROUP by src_university_id,dest_university_id;
