import java.io.File

object Main extends App {

/*
targeted_alarm_id,capture_time,src_university_id,dest_university_id,mail_send_status,subtype,generated_time,source_ip,src_country_code,destination_ip,dest_country_code,rule_name,source_user,destination_user,application,virtual_system,source_zone,destination_zone,log_forwarding_profile,repeat_cnt,source_port,destination_port,flags,protocol,action,alarm_name,threat_id,category,severity,direction,source_location,destination_location,content_type,file_digest,user_agent,file_type,x_forwarded_for,payload_flg
*/

	/*
     class Position(val id: Int, val name: String, val posX: Double, val posY: Double) {
          override def toString = "id: %d, name: %s, posX: %f, posY: %f".format(id, name, posX, posY)
	      }
	*/	      
    class Position(val targeted_alarm_id: Int,
    	  	   val capture_time: String,
		   val src_university_id: String,
    	  	   val dest_university_id: String,
		   val mail_send_status: String,
		   val subtype: String)
		   /*
		   val generated_time: String,
		   val source_ip: String,
		   val src_country_code: String,
		   val destination_ip: String,
		   val dest_country_code: String,
		   val rule_name: String,
		   val source_user: String,
		   val destination_user: String,
		   val application: String,
		   val virtual_system: String,
		   val source_zone: String,
		   val destination_zone: String,
		   val log_forwarding_profile: String,
		   val repeat_cnt: String,
		   val source_port: Int,
		   val destination_port: Int,
		   val flags: String,
		   val protocol: String,
		   val action: String,
		   val alarm_name: String,
		   val threat_id: Int,
		   val category: String,
		   val severity: String,
		   val direction: String,
		   val source_location: String,
		   val destination_location: String,
		   val content_type: String,
		   val file_digest: String,
		   val user_agent: String,
		   val file_type: String,
		   val x_forwarded_for: String,
		   payload_flg: String )
		   */
		   {

/*
    	  	   val dest_university_id: String,
		   val mail_send_status: String,
		   val subtype: String)
*/
        	   override def toString = "[%d]\ntargeted_alarm_id=%d\ncapture_time=%s\nsrc_university_id=%s\ndest_university_id=%s\n mail_send_status=%s\n subtype=%s\n".format(targeted_alarm_id, targeted_alarm_id, capture_time, src_university_id, dest_university_id, mail_send_status, subtype)
    }

    val csvFile = new File("target2-100")
    val list = MyCSVParser.parse(csvFile, r => new Position(
        r.get("targeted_alarm_id").toInt, r.get("capture_time"), r.get("src_university_id"),
	r.get("dest_university_id"), r.get("mail_send_status"), r.get("subtype")
    ))

    list.foreach(println)

}
