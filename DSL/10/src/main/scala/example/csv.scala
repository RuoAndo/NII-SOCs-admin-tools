import scala.io.Source
import java.io.PrintWriter

class PA2( val alarm_id: Int, val category: String,
               val sourceIP: String)

object PA2 {
  def apply( alarm_id: Int, category: String,
             sourceIP: String): PA2
     = new PA2( alarm_id, category, sourceIP )

  def unapply( pa2: PA2 )
     = Some( pa2.alarm_id, pa2.category,
             pa2.sourceIP )
}

object Main extends App {
 
    var source =Source.fromFile("1.csv","utf-8").getLines.foreach{
      a=>;
      var b=a.split(",");
      var line2 = b(0).toString + "," + b(5) + "," + b(7)
      println(line2)

      val pa2 = PA2(b(0).toInt, b(5), b(7))

      var consistency = pa2 match {
	  	case PA2 ( alarm_id, category, sourceIP)
		     => println("match")
		case _ => println("no match")
	  }
      }			
}

