import scala.io.Source
import java.io.PrintWriter

case class PA( source_IP: String, dest_IP: String, application: String, subtype: String)

object Main extends App {
 
    var source =Source.fromFile("1.csv","utf-8").getLines.foreach{
      a=>;

      var b=a.replaceAll("\"","").split(",");
      var pa = PA(b(4), b(6), b(11), b(12)) 

      val PA(source_IP, dest_IP, application, subtype) = pa
      
      pa match {
	 case PA(_, _, "google-play" , _) => println("match:" + pa)
	 case _ => println("not match:" + pa)
	 }

      }
}

