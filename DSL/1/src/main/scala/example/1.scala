// package jp.sf.amateras.scala.io

object SourceSample extends App {

  import scala.io._

  class Place(val name:String) {
    // override def toString = "@" + name
  }

  class ScheduleWithPlaceBuilder(val content:String,val place:Option[Place]) {
  	println("test")
	
       /*
    def from (startTime:Time) =
      new ScheduleStartTimeBuilder(content, startTime, place)
      */
    println("Spyware")
    
   }

  class contentBuilder(content:String) {

    def spyware(placeString:String) =
      new ScheduleWithPlaceBuilder(content,
                                   Some(new Place(placeString)))
  /*
    def from (startTime:Time) =
      new ScheduleStartTimeBuilder(content, startTime, None)
  */
  }

def address_format(line : String) = {
    val list = line split ','

    list.foreach(list => println(list))
    // println(list)

}

def dropQuote(str : String) : String = {
	        str drop 1 dropRight 1
}


  implicit def
    String2ContentBuilder(content:String) =
      new contentBuilder(content)
      
  {


    val filename = args(0)

    val source = Source.fromFile(filename, "UTF-8")

    var counter = 0;

    try {

          counter = 0;
	  source.getLines().foreach { line: String =>
          // println(line)
	  /// val ScheduleWithPlace = line
	  // println(ScheduleWithPlace)
	  address_format(line)
	  // counter = counter + 1;
      }
    } finally {

      source.close()
    }
  }
}