import scala.io.Source
import java.io.PrintWriter

case class PA (alarm_id: Int, category: String, sourceIP: String)

object Main extends App {

def caseClassMatchSample(pa: PA)
{
    pa match {
		case PA(_, "spyware" , _) => {
	     	     print("MATCH:spyware:->")
		     println(pa)
	     	       }
		case PA(_, "vulnerability" , _) => {
	     	     print("MATCH:vulnerability:->")
		     println(pa)
	     	       }
		case _ => {
	     	     print("NO MATCH:->")
	     	  }
	     }
}

def address_format(line : String, out : PrintWriter) = {
    val list = line split ','
    // caseClassMatchSample(PA(list(0).toInt, list(1).replaceAll(" ","_").toString))

    println("%s,%s,%s" format (list(0), list(5),list(7)))
    caseClassMatchSample(PA(list(0).toInt, list(5).toString, list(7).toString))
    // out.write("%s,%s,%s\n" format (list(0), list(5),list(7)))
    // println("%s,%s,%s" format (list(0), list(5),list(7)))
}

val source = Source.fromFile("1.csv", "utf8")
val out = new PrintWriter("out.txt", "utf8")

val lines = source.getLines
lines.foreach(line => address_format(line, out))
source.close
out.close
}

