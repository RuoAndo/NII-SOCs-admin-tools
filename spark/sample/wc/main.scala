import org.apache.spark.SparkContext

object Main {
  def main(args: Array[String]) {
    val sc = new SparkContext("local[*]", "App") // ローカルモード
    val rdd = sc.textFile("sample.txt")
      .flatMap(r => r.split(" "))
      .map(r => (r, 1))
      .cache
      .reduceByKey(_ + _)
      .collect.foreach { r => 
        println(r._1.mkString("", "", "") + "\t" + r._2)
      }

    sc.stop()
  }
}

