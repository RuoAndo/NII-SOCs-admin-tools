import scala.io.Source
import java.io.PrintWriter

// case class PA (alarm_id: Int, timestamp: String)

object Main extends App {

def caseClassMatchSample(pa: Int)
{
    pa match {
		case pa @ (77943409 | 77943413) => {
	     	  println("MATCH:" + pa)
	     	       }
		case _ => {
	     	  // println("NO MATCH")
	     	  }
	     }
}

def address_format(line : String, out : PrintWriter) = {
    val list = line split ','
    caseClassMatchSample(list(0).toInt)

    // val concat_str = list(0) + list(1)
    // caseClassMatchSample(PA(list(0).toInt, list(1).replaceAll(" ","_").toString))
    // out.write("%s,%s\n" format (list(0), list(1)))
}

val source = Source.fromFile("1.csv", "utf8")
val out = new PrintWriter("out.txt", "utf8")

val lines = source.getLines
lines.foreach(line => address_format(line, out))
source.close
out.close
}

