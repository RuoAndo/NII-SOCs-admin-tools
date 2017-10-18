select src_university_id,dest_university_id,count(capture_time) from session_info_20171015 
where capture_time >= '2017/10/15 07:13:59' and capture_time < '2017/10/15 07:18:59' 
GROUP by src_university_id,dest_university_id;
