import scala.io.Source
import java.io.PrintWriter

object csv {

var map: Map[String, String] = Map()

def csv_format(line : String, out : PrintWriter) = {
    val list = line split ','
    
    val timestamp = dropQuote(list(0))    
    val address = dropQuote(list(4)) + "," + dropQuote(list(7)) 

    map = map + (timestamp -> address)

    out.write("%s,%s\n" format (timestamp, address))
    print("%s,%s\n" format (timestamp, address))
}

// 前後のダブルクォーテーションを除去
def dropQuote(str : String) : String = {
    str drop 1 dropRight 1
}

  def main(args: Array[String]): Unit = {

  // 入力ファイル
  // val source = Source.fromFile("random_data.txt", "ms932")
  val source = Source.fromFile(args(0), "ms932")
  // 出力ファイル
  val out = new PrintWriter("random_data_output.txt", "utf8")

  // ファイルを読み込んでループ
  val lines = source.getLines
  lines.foreach(line => csv_format(line, out))
  source.close
  out.close

  map.foreach { e =>
  	     println(e._1 + "->" + "{" + e._2 + "}")
	     }
  }
}