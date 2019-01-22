import scala.io.Source
import java.io.PrintWriter

object Main extends App {
 
    var source =Source.fromFile("1.csv","utf-8").getLines.foreach{
      a=>;
      var b=a.split(",");
      var pa = b(25)
      // println(pa)

      regexMatchSample(pa.toString)

      def regexMatchSample(s: String): Unit = {
      val regex = """(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3}).*""".r
      val pattern2 = """(.+)((?i)web)(.+)""".r
      val pattern3 = """((?i)apple)(.+)""".r
      val pattern4 = """(.+)((?i)ASP)(.+)""".r
      
      s match {
        case regex(ip1,ip2,ip3,ip4) => println(ip1, ip2, ip3, ip4)
	
	case pattern2(str1,str2,str3) => s match {
	     	case pattern3(str1,str2) => println("MATCH:" + "[Apple]" + "," + s)
		case pattern4(str1,str2,str3) => println("MATCH:" + "[ASP]" + "," + s)
		case _ => // println("not match")
	}
	
	case _ => // println("not match")
	}
      }


    }
}

