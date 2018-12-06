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

    //郵便番号 zip = dropQuote(list(2))

    //住所
    //    val address = dropQuote(list(6)) + dropQuote(list(7)) + dropQuote(list(8))
    //	    out.write("%s,%s\n" format (zip, address))
}

// 前後のダブルクォーテーションを除去
def dropQuote(str : String) : String = {
	        str drop 1 dropRight 1
}


  implicit def
    String2ContentBuilder(content:String) =
      new contentBuilder(content)
      
  {
    println("-- ファイルの内容を読み込み --")

    val filename = args(0)
    // ファイルからSourceのインスタンスを生成
    val source = Source.fromFile(filename, "UTF-8")

    var counter = 0;

    try {
      // 1行毎の文字列を返すIteratorを取得して表示
          counter = 0;
	  source.getLines().foreach { line: String =>
          // println(line)
	  /// val ScheduleWithPlace = line
	  // println(ScheduleWithPlace)
	  address_format(line)
	  // counter = counter + 1;
      }
    } finally {
      // クローズ
      source.close()
    }
  }
}