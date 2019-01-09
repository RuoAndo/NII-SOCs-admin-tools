import scala.io.Source
import java.io.PrintWriter

object Main extends App {
 
    var source =Source.fromFile("1.csv","utf-8").getLines.foreach{
      a=>;
      var b=a.split(",");
      var pa = b(7)
      println(pa)
      regexMatchSample(pa.toString)

      def regexMatchSample(s: String): Unit = {
      val regex = """(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3}).*""".r
      // val pattern = """/(?<!\d)\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(?!\d)/""".r
      val pattern2 = """(.+).(.+).(.+).(.+)""".r
      s match {
        case regex(ip1,ip2,ip3,ip4) => println(ip1, ip2, ip3, ip4)
      	// case pattern(a, b, c, d) => println("111-2222の場合")
	// case pattern2(a, b, c ,d) => println("パターンにマッチしました（%s %s %s %s）".format(a, b, c, d))
	case _ => println("マッチしませんでした")
	}
      }                     
    }
}

