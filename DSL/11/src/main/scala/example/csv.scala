import scala.io.Source
import java.io.PrintWriter

case class PA( alarm_id: String, category: String, sourceIP: String)

object Main extends App {
 
    var source =Source.fromFile("1.csv","utf-8").getLines.foreach{
      a=>;
      var b=a.split(",");
      var pa = PA(b(0), b(5), b(7))
      // println(pa)

      val PA(alarm_id, category, sourceIP) = pa

      pa match {
      	 // case PA(alarm_id, category, sourceIP) => println("match")
	 case PA(_, "spyware", _) => println("match:" + pa)
	 case _ => println("not match:" + pa)
	 }
}
}

