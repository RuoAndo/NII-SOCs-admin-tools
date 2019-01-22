import scala.io.Source
import java.io.PrintWriter

class spyware ( val alarm_id:Int, val spyware:String, val sourceIP:String) {

      if( spyware == null ) throw new IllegalArgumentException( "spyware name is null" )

      /*
      def toURL = new java.net.URL( this.toString )

      override def toString = {
      	       val portString = if( portNo == 443 ) "" else ":" + portNo
      	       val pathString = if( path.isEmpty ) "" else path.mkString("/")
      	       "http://%s%s/%s" format( hostname, portString, pathString )
      }
      */
}

object spyware {
  def display(spyware:String) = {
      println("display from companion object:" + spyware)
  }
}

case class PA( alarm_id: String, category: String, sourceIP: String)

object Main extends App {
 
    var source =Source.fromFile("1.csv","utf-8").getLines.foreach{
      a=>;
      var b=a.split(",");
         var pa = PA(b(0), b(5), b(7))
      println(pa)

      // println(b(0) + "," + b(5))

      val PA(alarm_id, category, sourceIP) = pa

      pa match {
      	 // case PA(alarm_id, category, sourceIP) => println("match")
	 case PA(_, "spyware", _) =>
	 
	 println("match:" + pa)
	 val testsample = spyware.display( "spyware" )

	 case _ => println("not match:" + pa)
	 }
}
}

