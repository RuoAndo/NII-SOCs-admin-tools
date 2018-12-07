package example

import scala.io.Source

object Hello extends Greeting with App {
  println(greeting)

  var source = Source.fromFile("filename")
  val lines = source.getLines
  lines.foreach(println)
  //=> test
  source.close

}

trait Greeting {
  lazy val greeting: String = "hello"
}


  
